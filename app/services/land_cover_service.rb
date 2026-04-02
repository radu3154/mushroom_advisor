require "net/http"
require "json"
require "uri"
require "set"

class LandCoverService
  # Primary + fallback Overpass instances for resilience.
  # The main server is in Germany; Kumi is a community mirror.
  OVERPASS_URLS = [
    "https://overpass-api.de/api/interpreter",
    "https://overpass.kumi.systems/api/interpreter"
  ].freeze

  # In-memory terrain cache — terrain doesn't change, so cache by rounded coords.
  # Key: "lat,lon" rounded to 2 decimals (~1.1km precision). Max 2000 entries.
  # 2 decimals is fine: terrain doesn't change within ~1km, and it massively
  # increases cache hit rate for nearby pins.
  @terrain_cache = {}
  @cache_mutex = Mutex.new

  def self.cache_key(lat, lon)
    "#{lat.round(2)},#{lon.round(2)}"
  end

  def self.cached_overpass(lat, lon)
    key = cache_key(lat, lon)
    @cache_mutex.synchronize { @terrain_cache[key] }
  end

  def self.store_cache(lat, lon, result)
    key = cache_key(lat, lon)
    @cache_mutex.synchronize do
      @terrain_cache.shift if @terrain_cache.size >= 2000
      @terrain_cache[key] = result
    end
  end

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
  # Two-phase detect: can run without elevation (for parallel execution),
  # then refine_with_elevation() is called once weather data arrives.
  # If elevation is provided upfront, does everything in one call.
  def self.detect(lat:, lon:, elevation: nil)
    result = query_overpass(lat, lon)

    if result[:type] != "unknown"
      if result[:meta] != :forest_no_leaf_type
        # Grassland may need elevation refinement for alpine meadow
        if result[:type] == "grassland"
          if elevation && elevation >= 1800
            return { type: "grassland", label_en: "Alpine meadow", label_ro: "Pajiște alpină", source: "osm+elevation" }
          elsif elevation.nil?
            return result.merge(needs_elevation: true)
          end
        end
        return result.except(:meta)
      end
    end

    # Needs elevation to resolve forest type or unknown terrain
    if elevation
      return refine_with_elevation(result, elevation)
    end

    # No elevation yet — flag for later refinement
    result.merge(needs_elevation: true)
  rescue => e
    Rails.logger.warn "LandCoverService error: #{e.message}"
    { type: "unknown", label_en: "Unknown terrain", label_ro: "Teren nedetectat", source: "error" }
  end

  # Second phase: refine terrain result using elevation from weather API.
  # Called by controller after parallel fetch completes.
  def self.refine_with_elevation(result, elevation)
    result = result.except(:needs_elevation)

    if result[:type] == "grassland" && elevation && elevation >= 1800
      return { type: "grassland", label_en: "Alpine meadow", label_ro: "Pajiște alpină", source: "osm+elevation" }
    end

    # Nothing found + at or below sea level → water (open sea, lake surface).
    if result[:type] == "unknown" && elevation && elevation <= 0
      return terrain_result("water", "elevation")
    end

    if elevation && (result[:meta] == :forest_no_leaf_type || (result[:type] == "unknown" && elevation >= 400))
      guess = elevation_guess(elevation)
      return guess if guess
    end

    if result[:meta] == :forest_no_leaf_type
      return { type: "deciduous", label_en: "Deciduous forest", label_ro: "Pădure de foioase", source: "osm_default" }
    end

    result.except(:meta)
  end

  private

  def self.query_overpass(lat, lon)
    # Return cached result if available (terrain doesn't change)
    cached = cached_overpass(lat, lon)
    return cached if cached

    query = <<~OQL
      [out:json][timeout:6];
      is_in(#{lat},#{lon})->.enclosing;
      (
        area.enclosing["landuse"];
        area.enclosing["natural"];
        area.enclosing["leisure"];
        way["landuse"](around:300,#{lat},#{lon});
        way["natural"](around:300,#{lat},#{lon});
        way["leisure"](around:300,#{lat},#{lon});
        way["waterway"](around:100,#{lat},#{lon});
        relation["natural"="water"](around:500,#{lat},#{lon});
        relation["water"](around:500,#{lat},#{lon});
      );
      out tags;
    OQL

    # Try each Overpass server with tight timeouts; fall back to elevation-only
    OVERPASS_URLS.each do |base_url|
      begin
        uri = URI.parse(base_url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.open_timeout = 5
        http.read_timeout = 7

        request = Net::HTTP::Post.new(uri.request_uri)
        request.set_form_data("data" => query)

        response = http.request(request)
        next unless response.is_a?(Net::HTTPSuccess)

        data = JSON.parse(response.body)
        elements = data["elements"] || []

        result = parse_overpass_elements(elements)
        store_cache(lat, lon, result)
        return result
      rescue Net::OpenTimeout, Net::ReadTimeout, StandardError => e
        Rails.logger.warn "Overpass #{base_url} failed: #{e.message}"
        next
      end
    end

    # All Overpass servers failed — return unknown, let elevation fallback handle it
    Rails.logger.warn "All Overpass servers failed for #{lat},#{lon}"
    { type: "unknown", label_en: "Unknown terrain", label_ro: "Teren nedetectat", source: "api_error" }
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
    "pasture"    => :grassland,
    # natural values
    "wood"       => :forest,
    "grassland"  => :grassland,
    "scrub"      => :scrubland,
    "heath"      => :grassland,
    "wetland"    => :grassland,
    "fell"       => :grassland,
    # water bodies — tell the user they're on water, not land
    "water"      => :water,
    "lake"       => :water,
    "pond"       => :water,
    "reservoir"  => :water,
    "basin"      => :water,
    "riverbank"  => :water,
    "sea"        => :water,
    "bay"        => :water,
    "strait"     => :water,
  }.freeze

  # Large-scale geographic features that don't describe local land cover.
  # These get returned by is_in() for huge enclosing relations (e.g. the entire
  # Carpathian range) and must be IGNORED so we fall through to real land cover
  # or the elevation-based fallback.
  IGNORE_TAGS = %w[
    mountain_range ridge peak saddle cliff volcano
    peninsula coastline
    continent country state region county
    protected_area national_park
  ].to_set.freeze

  TERRAIN_LABELS = {
    deciduous:  { en: "Deciduous forest",  ro: "Pădure de foioase" },
    coniferous: { en: "Coniferous forest",  ro: "Pădure de conifere" },
    mixed:      { en: "Mixed forest",       ro: "Pădure mixtă" },
    grassland:  { en: "Meadow",             ro: "Pajiște" },
    orchard:    { en: "Orchard",            ro: "Livadă" },
    scrubland:  { en: "Scrubland",          ro: "Tufăriș" },
    farmland:   { en: "Farmland",           ro: "Teren agricol" },
    park:       { en: "Park",               ro: "Parc" },
    water:      { en: "Water",              ro: "Apă" },
  }.freeze

  def self.parse_overpass_elements(elements)
    return { type: "unknown", label_en: "Unknown terrain", label_ro: "Teren nedetectat", source: "none" } if elements.empty?

    # Collect all landuse and natural tags
    categories = { forest: [], grassland: [], orchard: [], scrubland: [], farmland: [], park: [], water: [], other: [] }

    elements.each do |e|
      tags = e["tags"] || {}
      landuse = tags["landuse"]
      natural = tags["natural"]
      leisure = tags["leisure"]
      waterway = tags["waterway"]
      water = tags["water"]

      # Waterway tags (river, stream, canal) or water tags (lake, reservoir, pond)
      if waterway || water
        categories[:water] << e
        next
      end

      tag_val = landuse || natural || leisure
      next if tag_val && IGNORE_TAGS.include?(tag_val)

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

    # 2-7. Other terrain types in priority order (water last — land cover wins)
    %i[orchard grassland scrubland farmland park water].each do |cat|
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
