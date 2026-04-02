require "net/http"
require "json"
require "uri"
require "set"

class LandCoverService
  # Nominatim reverse geocoding — fast, reliable, and great at detecting water.
  # Replaces Overpass API which was too slow (3-10s) and unreliable for real-time use.
  NOMINATIM_URL = "https://nominatim.openstreetmap.org/reverse".freeze

  # In-memory terrain cache — terrain doesn't change, so cache by rounded coords.
  # Key: "lat,lon" rounded to 2 decimals (~1.1km precision). Max 2000 entries.
  @terrain_cache = {}
  @cache_mutex = Mutex.new

  def self.cache_key(lat, lon)
    "#{lat.round(2)},#{lon.round(2)}"
  end

  def self.cached_terrain(lat, lon)
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

  # Nominatim "type" values that indicate water
  WATER_TYPES = Set.new(%w[
    water lake pond reservoir basin riverbank
    sea bay strait river stream canal
  ]).freeze

  # Nominatim "type" values → our terrain categories
  TERRAIN_MAP = {
    # landuse types
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
    # natural types
    "wood"       => :forest,
    "grassland"  => :grassland,
    "scrub"      => :scrubland,
    "heath"      => :grassland,
    "wetland"    => :grassland,
    "fell"       => :grassland,
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
    water:      { en: "Water",              ro: "Apă" },
  }.freeze

  # Two-phase detect: can run without elevation (for parallel execution),
  # then refine_with_elevation() is called once weather data arrives.
  def self.detect(lat:, lon:, elevation: nil)
    result = query_terrain(lat, lon)

    # Water is definitive — no elevation refinement needed
    return result if result[:type] == "water"

    if result[:type] != "unknown"
      if result[:meta] != :forest_no_leaf_type
        # Grassland may need elevation refinement for alpine meadow
        if result[:type] == "grassland"
          if elevation && elevation >= 1800
            return { type: "grassland", label_en: "Alpine meadow", label_ro: "Pajiște alpină", source: "nominatim+elevation" }
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
      return { type: "grassland", label_en: "Alpine meadow", label_ro: "Pajiște alpină", source: "nominatim+elevation" }
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
      return { type: "deciduous", label_en: "Deciduous forest", label_ro: "Pădure de foioase", source: "nominatim_default" }
    end

    result.except(:meta)
  end

  private

  def self.query_terrain(lat, lon)
    cached = cached_terrain(lat, lon)
    return cached if cached

    result = query_nominatim(lat, lon)
    store_cache(lat, lon, result)
    result
  end

  def self.query_nominatim(lat, lon)
    uri = URI("#{NOMINATIM_URL}?format=json&lat=#{lat}&lon=#{lon}&zoom=18&addressdetails=0")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 3
    http.read_timeout = 3

    request = Net::HTTP::Get.new(uri)
    request["User-Agent"] = "SfatulCiupercarului/1.0 (mushroom-foraging-advisor)"
    request["Accept-Language"] = "en"

    response = http.request(request)
    unless response.is_a?(Net::HTTPSuccess)
      Rails.logger.warn "Nominatim returned #{response.code}"
      return unknown_result("api_error")
    end

    data = JSON.parse(response.body)
    parse_nominatim_response(data)
  rescue Net::OpenTimeout, Net::ReadTimeout => e
    Rails.logger.warn "Nominatim timeout: #{e.message}"
    unknown_result("timeout")
  rescue => e
    Rails.logger.warn "Nominatim error: #{e.message}"
    unknown_result("error")
  end

  # Parse a Nominatim reverse-geocoding response into our terrain format.
  # Nominatim returns { "class": "natural", "type": "water", ... } etc.
  def self.parse_nominatim_response(data)
    return unknown_result("empty") if data.nil? || data.empty?
    return unknown_result("not_found") if data["error"]

    osm_class = data["class"].to_s
    osm_type = data["type"].to_s

    # 1. Water detection — waterway class or water-related type
    if osm_class == "waterway" || WATER_TYPES.include?(osm_type)
      return terrain_result("water", "nominatim")
    end

    # 2. Standard terrain from type
    cat = TERRAIN_MAP[osm_type]
    if cat
      if cat == :forest
        # Nominatim doesn't tell us leaf type — flag for elevation refinement
        return { type: "unknown", label_en: "Forest (type unknown)",
                 label_ro: "Pădure (tip neidentificat)",
                 source: "nominatim", meta: :forest_no_leaf_type }
      end
      return terrain_result(cat.to_s, "nominatim")
    end

    # 3. Parks and leisure areas
    if osm_class == "leisure" && %w[park garden nature_reserve].include?(osm_type)
      return terrain_result("park", "nominatim")
    end

    # 4. Nothing matched — will be refined by elevation
    unknown_result("none")
  end

  def self.unknown_result(source)
    { type: "unknown", label_en: "Unknown terrain", label_ro: "Teren nedetectat", source: source }
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
