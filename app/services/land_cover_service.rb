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
    return result if result[:type] != "unknown"

    # Fallback to elevation when Overpass can't determine type:
    # - Forest found but no leaf_type tag
    # - Nothing found but we're above 400m (likely forested hills/mountains)
    if elevation && (result[:meta] == :forest_no_leaf_type || elevation >= 400)
      guess = elevation_guess(elevation)
      return guess if guess
    end

    result.except(:meta)
  rescue => e
    Rails.logger.warn "LandCoverService error: #{e.message}"
    { type: "unknown", label_en: "Unknown terrain", label_ro: "Teren nedetectat", source: "error" }
  end

  private

  def self.query_overpass(lat, lon)
    # Use is_in to find what area the point falls inside (works for large forests)
    # plus around:300 as fallback for smaller features not mapped as areas
    query = <<~OQL
      [out:json][timeout:10];
      is_in(#{lat},#{lon})->.enclosing;
      (
        area.enclosing["landuse"="forest"];
        area.enclosing["natural"="wood"];
        area.enclosing["landuse"="meadow"];
        area.enclosing["landuse"="grass"];
        area.enclosing["natural"="grassland"];
        way["landuse"="forest"](around:300,#{lat},#{lon});
        way["natural"="wood"](around:300,#{lat},#{lon});
        way["landuse"="meadow"](around:300,#{lat},#{lon});
        way["natural"="grassland"](around:300,#{lat},#{lon});
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

  def self.parse_overpass_elements(elements)
    return { type: "unknown", label_en: "Unknown terrain", label_ro: "Teren nedetectat", source: "none" } if elements.empty?

    # Check for forest/wood first (higher priority for mushroom hunting)
    forests = elements.select { |e| %w[forest wood].include?(e.dig("tags", "landuse")) || %w[wood].include?(e.dig("tags", "natural")) }
    grasslands = elements.select { |e| %w[meadow grass].include?(e.dig("tags", "landuse")) || e.dig("tags", "natural") == "grassland" }

    if forests.any?
      # Check if any forest has leaf_type tagged
      leaf_types = forests.map { |e| e.dig("tags", "leaf_type") }.compact
      if leaf_types.include?("broadleaved")
        return { type: "deciduous", label_en: "Deciduous forest", label_ro: "Pădure de foioase", source: "osm" }
      elsif leaf_types.include?("needleleaved")
        return { type: "coniferous", label_en: "Coniferous forest", label_ro: "Pădure de conifere", source: "osm" }
      elsif leaf_types.include?("mixed")
        return { type: "mixed", label_en: "Mixed forest", label_ro: "Pădure mixtă", source: "osm" }
      else
        # Forest found but no leaf_type tag — will fall back to elevation
        return { type: "unknown", label_en: "Forest (type unknown)", label_ro: "Pădure (tip neidentificat)", source: "osm_partial", meta: :forest_no_leaf_type }
      end
    end

    if grasslands.any?
      return { type: "grassland", label_en: "Meadow", label_ro: "Pajiște", source: "osm" }
    end

    { type: "unknown", label_en: "Unknown terrain", label_ro: "Teren nedetectat", source: "none" }
  end

  def self.elevation_guess(elevation)
    band = ELEVATION_BANDS.find { |b| b[:range].include?(elevation) }
    return nil unless band

    { type: band[:type], label_en: band[:label_en], label_ro: band[:label_ro], source: "elevation" }
  end
end
