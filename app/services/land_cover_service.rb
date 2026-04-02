require "net/http"
require "json"
require "uri"

class LandCoverService
  OVERPASS_URL = "https://overpass-api.de/api/interpreter".freeze

  # Romanian elevation bands (approximate):
  #   0–400m   — plains/lowland, could be anything (urban, farmland, forest)
  #   400–1000m — hills, mostly deciduous (fag, stejar, carpen)
  #   1000–1400m — mountain transition, mixed forests
  #   1400–1800m — upper mountain, mostly coniferous (molid, brad, pin)
  #   >1800m   — alpine meadow, above treeline
  ELEVATION_BANDS = [
    { range: (1800..), type: "grassland",  label_en: "Alpine meadow",    label_ro: "Pajiște alpină" },
    { range: (1400...1800), type: "coniferous", label_en: "Coniferous forest", label_ro: "Pădure de conifere" },
    { range: (1000...1400), type: "mixed",      label_en: "Mixed forest",      label_ro: "Pădure mixtă" },
    { range: (400...1000),  type: "deciduous",  label_en: "Deciduous forest",  label_ro: "Pădure de foioase" },
  ].freeze

  # Returns a hash like:
  #   { type: "deciduous",  label_en: "Deciduous forest", label_ro: "Pădure de foioase",  source: "osm" }
  #   { type: "coniferous", label_en: "Coniferous forest", label_ro: "Pădure de conifere", source: "elevation" }
  #   { type: "grassland",  label_en: "Meadow",            label_ro: "Pajiște",             source: "osm" }
  #   { type: "unknown",    label_en: "Unknown terrain",    label_ro: "Teren nedetectat",    source: "none" }
  def self.detect(lat:, lon:, elevation: nil)
    result = query_overpass(lat, lon)

    if result[:type] != "unknown"
      # Refine labels using elevation where it adds info:
      # - Grassland above 1800m → "Alpine meadow" (not just "Meadow")
      # - Forest without leaf_type → use elevation band to determine type
      if result[:type] == "grassland" && elevation && elevation >= 1800
        return { type: "grassland", label_en: "Alpine meadow", label_ro: "Pajiște alpină", source: "osm+elevation" }
      end

      if result[:meta] != :forest_no_leaf_type
        return result
      end
    end

    # Fallback to elevation when Overpass can't determine type:
    # - Forest found but no leaf_type tag
    # - Nothing found but we're above 400m (likely forested hills/mountains)
    if elevation && (result[:meta] == :forest_no_leaf_type || elevation >= 400)
      guess = elevation_guess(elevation)
      return guess if guess
    end

    # If Overpass confirmed a forest but elevation band didn't match either
    # (e.g. lowland < 400m), default to deciduous — lowland Romanian forests
    # are almost exclusively broadleaf (stejar, fag, carpen)
    if result[:meta] == :forest_no_leaf_type
      return { type: "deciduous", label_en: "Deciduous forest", label_ro: "Pădure de foioase", source: "osm_default" }
    end

    result.except(:meta)
  rescue => e
    Rails.logger.warn "LandCoverService error: #{e.message}"
    { type: "unknown", label_en: "Unknown terrain", label_ro: "Teren nedetectat", source: "error" }
  end

  private

  def self.query_overpass(lat, lon)
    # Query for ANY landuse/natural tag — catch everything, classify in Ruby.
    # is_in finds enclosing areas; around:500 catches nearby smaller features.
    query = <<~OQL
      [out:json][timeout:12];
      is_in(#{lat},#{lon})->.enclosing;
      (
        area.enclosing["landuse"];
        area.enclosing["natural"];
        area.enclosing["leisure"];
        way["landuse"](around:500,#{lat},#{lon});
        way["natural"](around:500,#{lat},#{lon});
        way["leisure"](around:500,#{lat},#{lon});
        relation["landuse"](around:500,#{lat},#{lon});
        relation["natural"](around:500,#{lat},#{lon});
      );
      out tags;
    OQL

    uri = URI.parse(OVERPASS_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 10
    http.read_timeout = 15

    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data("data" => query)

    response = http.request(request)
    unless response.is_a?(Net::HTTPSuccess)
      Rails.logger.warn "Overpass API returned #{response.code}"
      return { type: "unknown", label_en: "Unknown terrain", label_ro: "Teren nedetectat", source: "api_error" }
    end

    data = JSON.parse(response.body)
    elements = data["elements"] || []

    parse_overpass_elements(elements)
  end

  # Mushroom-relevant terrain classification from OSM tags.
  # Priority: forest > orchard > grassland > scrub > farmland > park > other detected > unknown
  TERRAIN_MAP = {
    # landuse values
    "forest"     => :forest,
    "meadow"     => :grassland,
    "grass"      => :grassland,
    "orchard"    => :orchard,
    "vineyard"   => :farmland,
    "farmland"   => :farmland,
    "allotments" => :farmland,
    "village_green" => :grassland,
    "recreation_ground" => :grassland,
    # natural values
    "wood"       => :forest,
    "grassland"  => :grassland,
    "scrub"      => :scrubland,
    "heath"      => :grassland,
    "wetland"    => :grassland,
  }.freeze

  TERRAIN_LABELS = {
    deciduous:  { en: "Deciduous forest",  ro: "Pădure de foioase" },
    coniferous: { en: "Coniferous forest",  ro: "Pădure de conifere" },
    mixed:      { en: "Mixed forest",       ro: "Pădure mixtă" },
    grassland:  { en: "Meadow",             ro: "Pajiște" },
    orchard:    { en: "Orchard",            ro: "Livadă" },
    scrubland:  { en: "Scrubland",          ro: "Tufăriș" },
    farmland:   { en: "Farmland",           ro: "Teren agricol" },
    park:       { en: "Park",               ro: "Parc" },
  }.freeze

  def self.parse_overpass_elements(elements)
    return { type: "unknown", label_en: "Unknown terrain", label_ro: "Teren nedetectat", source: "none" } if elements.empty?

    # Collect all landuse and natural tags
    categories = { forest: [], grassland: [], orchard: [], scrubland: [], farmland: [], park: [], other: [] }

    elements.each do |e|
      tags = e["tags"] || {}
      landuse = tags["landuse"]
      natural = tags["natural"]
      leisure = tags["leisure"]

      tag_val = landuse || natural || leisure
      cat = TERRAIN_MAP[tag_val]

      if cat
        categories[cat] << e
      elsif leisure && %w[park garden nature_reserve].include?(leisure)
        categories[:park] << e
      elsif tag_val
        categories[:other] << e
      end
    end

    # 1. Forest/wood — highest priority, try to determine leaf type
    if categories[:forest].any?
      leaf_types = categories[:forest].map { |e| e.dig("tags", "leaf_type") }.compact
      if leaf_types.include?("broadleaved")
        return terrain_result("deciduous", "osm")
      elsif leaf_types.include?("needleleaved")
        return terrain_result("coniferous", "osm")
      elsif leaf_types.include?("mixed")
        return terrain_result("mixed", "osm")
      else
        return { type: "unknown", label_en: "Forest (type unknown)", label_ro: "Pădure (tip neidentificat)", source: "osm_partial", meta: :forest_no_leaf_type }
      end
    end

    # 2-6. Other terrain types in priority order
    %i[orchard grassland scrubland farmland park].each do |cat|
      if categories[cat].any?
        return terrain_result(cat.to_s, "osm")
      end
    end

    # 7. Something was found but not in our map — still better than "unknown"
    if categories[:other].any?
      first = categories[:other].first["tags"] || {}
      tag = first["landuse"] || first["natural"] || first["leisure"] || "detected"
      return { type: "other", label_en: tag.tr("_", " ").capitalize, label_ro: tag.tr("_", " ").capitalize, source: "osm" }
    end

    { type: "unknown", label_en: "Unknown terrain", label_ro: "Teren nedetectat", source: "none" }
  end

  def self.terrain_result(type, source)
    labels = TERRAIN_LABELS[type.to_sym]
    if labels
      { type: type, label_en: labels[:en], label_ro: labels[:ro], source: source }
    else
      { type: type, label_en: type.tr("_", " ").capitalize, label_ro: type.tr("_", " ").capitalize, source: source }
    end
  end

  def self.elevation_guess(elevation)
    band = ELEVATION_BANDS.find { |b| b[:range].include?(elevation) }
    return nil unless band

    { type: band[:type], label_en: band[:label_en], label_ro: band[:label_ro], source: "elevation" }
  end
end
