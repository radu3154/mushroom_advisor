require "net/http"
require "json"
require "uri"
require "set"

class LandCoverService
  # ── API endpoints ────────────────────────────────────────────────────
  # Three-tier terrain detection:
  #
  # 1. Overpass is_in() — PRIMARY. Fast point-in-polygon check (~200-500ms).
  #    Uses is_in() (spatial index lookup). Detects water, forests, farmland, parks.
  #
  # 2. Overpass around:150 — NEARBY FALLBACK. Only runs when is_in() returns empty
  #    (the point isn't inside any mapped polygon). Searches for landuse/natural
  #    features within 150m. Catches unmapped gaps between polygons (~300-800ms).
  #    Many rural areas in Romania have incomplete OSM polygon coverage but have
  #    nearby features that reveal the actual terrain.
  #
  # 3. Nominatim reverse geocode — LAST RESORT. Runs in parallel with Overpass.
  #    Returns nearest address, not land cover — often gives roads/buildings
  #    instead of the forest/lake you're standing on.
  #
  # Overpass (is_in → around) runs first; Nominatim runs in parallel as backup.
  NOMINATIM_URL = "https://nominatim.openstreetmap.org/reverse".freeze
  OVERPASS_URLS = [
    "https://overpass-api.de/api/interpreter",
    "https://overpass.kumi.systems/api/interpreter"
  ].freeze

  # ── In-memory cache ──────────────────────────────────────────────────
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

  # ── Elevation bands (Romanian geography) ─────────────────────────────
  ELEVATION_BANDS = [
    { range: (1800..), type: "grassland",  label_en: "Alpine meadow",    label_ro: "Pajiște alpină" },
    { range: (1400...1800), type: "coniferous", label_en: "Coniferous forest", label_ro: "Pădure de conifere" },
    { range: (1000...1400), type: "mixed",      label_en: "Mixed forest",      label_ro: "Pădure mixtă" },
    { range: (400...1000),  type: "deciduous",  label_en: "Deciduous forest",  label_ro: "Pădure de foioase" },
  ].freeze

  # ── Terrain classification maps ──────────────────────────────────────

  WATER_TYPES = Set.new(%w[
    water lake pond reservoir basin riverbank
    sea bay strait river stream canal
  ]).freeze

  TERRAIN_MAP = {
    "forest"     => :forest,   "wood"       => :forest,
    "meadow"     => :grassland, "grass"     => :grassland,
    "grassland"  => :grassland, "pasture"   => :grassland,
    "heath"      => :grassland, "fell"      => :grassland,
    "wetland"    => :grassland,
    "village_green" => :grassland, "recreation_ground" => :grassland,
    "orchard"    => :orchard,
    "vineyard"   => :farmland,  "farmland"  => :farmland,
    "allotments" => :farmland,
    "scrub"      => :scrubland,
  }.freeze

  # Large-scale geographic features to ignore from is_in() results.
  IGNORE_TAGS = Set.new(%w[
    mountain_range ridge peak saddle cliff volcano
    peninsula coastline
    continent country state region county
    protected_area national_park
  ]).freeze

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

  # Romanian translations for OSM tags that fall outside the main terrain categories.
  # These appear in the "other" bucket (residential, industrial, etc.) or
  # when terrain_result encounters a type not in TERRAIN_LABELS.
  OTHER_LABELS_RO = {
    "residential"        => "Zonă rezidențială",
    "industrial"         => "Zonă industrială",
    "commercial"         => "Zonă comercială",
    "retail"             => "Zonă comercială",
    "construction"       => "Șantier",
    "quarry"             => "Carieră",
    "landfill"           => "Groapă de gunoi",
    "military"           => "Zonă militară",
    "railway"            => "Cale ferată",
    "cemetery"           => "Cimitir",
    "sand"               => "Nisip",
    "bare_rock"          => "Stâncă",
    "scree"              => "Grohotiș",
    "mud"                => "Noroi",
    "beach"              => "Plajă",
    "cliff"              => "Faleza",
    "glacier"            => "Ghețar",
    "brownfield"         => "Teren viran",
    "greenfield"         => "Teren liber",
    "garages"            => "Garaje",
    "playground"         => "Loc de joacă",
    "sports_centre"      => "Complex sportiv",
    "pitch"              => "Teren de sport",
    "stadium"            => "Stadion",
    "swimming_pool"      => "Piscină",
    "golf_course"        => "Teren de golf",
    "marina"             => "Port turistic",
    "village_green"      => "Pajiște",
    "recreation_ground"  => "Teren de agrement",
    "reservoir"          => "Rezervor de apă",
    "basin"              => "Bazin",
    "plant_nursery"      => "Pepinieră",
    "flowerbed"          => "Strat de flori",
    "religious"          => "Loc de cult",
    "education"          => "Instituție de învățământ",
    "depot"              => "Depozit",
  }.freeze

  # ── Public API ───────────────────────────────────────────────────────

  def self.detect(lat:, lon:, elevation: nil)
    # Hard override: elevation <= 0 means water (sea, below sea level).
    # Must check BEFORE terrain detection — around:150 can pick up
    # coastal features (meadows, beaches) when standing in the sea.
    if elevation && elevation <= 0
      return terrain_result("water", "elevation")
    end

    result = query_terrain(lat, lon)

    return result if result[:type] == "water"

    if result[:type] != "unknown"
      if result[:meta] != :forest_no_leaf_type
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

    if elevation
      return refine_with_elevation(result, elevation)
    end

    result.merge(needs_elevation: true)
  rescue => e
    Rails.logger.warn "LandCoverService error: #{e.message}"
    { type: "unknown", label_en: "Unknown terrain", label_ro: "Teren nedetectat", source: "error" }
  end

  def self.refine_with_elevation(result, elevation)
    result = result.except(:needs_elevation)

    if result[:type] == "grassland" && elevation && elevation >= 1800
      return { type: "grassland", label_en: "Alpine meadow", label_ro: "Pajiște alpină", source: "osm+elevation" }
    end

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

  # ── Query orchestration ──────────────────────────────────────────────
  # Run Overpass (primary) and Nominatim (fallback) in parallel.
  # Overpass is_in() is accurate for land cover — it checks what polygon
  # you're inside of. Nominatim returns the nearest address, which often
  # misses forests, lakes, and farmland.
  def self.query_terrain(lat, lon)
    cached = cached_terrain(lat, lon)
    return cached if cached

    overpass_result = nil
    nominatim_result = nil

    # Overpass and Nominatim run in parallel.
    # Overpass uses a persistent connection: is_in() + nearby reuse one TCP+SSL
    # handshake instead of two — saves ~100-200ms on the fallback path.
    t0 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    t_overpass  = Thread.new { overpass_result  = query_overpass(lat, lon) }
    t_nominatim = Thread.new { nominatim_result = query_nominatim(lat, lon) }

    t_overpass.join
    t_nominatim.join
    elapsed = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - t0) * 1000).round
    Rails.logger.info "LandCover [#{lat.round(2)},#{lon.round(2)}]: #{elapsed}ms | " \
                      "type=#{overpass_result&.dig(:type) || nominatim_result&.dig(:type) || 'nil'} " \
                      "src=#{overpass_result&.dig(:source) || nominatim_result&.dig(:source) || 'none'}"

    # Prefer Overpass (accurate polygon match) over Nominatim (nearest address).
    result = if overpass_result && (overpass_result[:type] != "unknown" || overpass_result[:meta] == :forest_no_leaf_type)
               overpass_result
             elsif nominatim_result && (nominatim_result[:type] != "unknown" || nominatim_result[:meta] == :forest_no_leaf_type)
               nominatim_result
             else
               overpass_result || nominatim_result || unknown_result("none")
             end

    store_cache(lat, lon, result)
    result
  end

  # ── Overpass: persistent-connection is_in + nearby ──────────────────
  # Uses Net::HTTP.start to keep one TCP+SSL connection open for both
  # queries. The nearby fallback reuses the same socket — no second
  # handshake, saving ~100-200ms when is_in() returns unknown.
  IS_IN_OQL = proc { |lat, lon| <<~OQL }
    [out:json][timeout:3];
    is_in(#{lat},#{lon})->.a;
    (
      area.a["landuse"];
      area.a["natural"];
      area.a["leisure"];
      area.a["water"];
    );
    out tags;
  OQL

  NEARBY_OQL = proc { |lat, lon| <<~OQL }
    [out:json][timeout:3];
    (
      way["landuse"](around:150,#{lat},#{lon});
      way["natural"](around:150,#{lat},#{lon});
      way["leisure"](around:150,#{lat},#{lon});
      way["water"](around:150,#{lat},#{lon});
      relation["landuse"](around:150,#{lat},#{lon});
      relation["natural"](around:150,#{lat},#{lon});
      relation["water"](around:150,#{lat},#{lon});
    );
    out tags 3;
  OQL

  def self.query_overpass(lat, lon)
    OVERPASS_URLS.each do |base_url|
      begin
        uri = URI.parse(base_url)

        # Persistent connection — one TCP+SSL handshake for both queries.
        Net::HTTP.start(uri.host, uri.port, use_ssl: true,
                        open_timeout: 2, read_timeout: 3) do |http|

          # Step 1: is_in() — fast point-in-polygon (~200-500ms)
          result = run_overpass_on(http, uri, IS_IN_OQL.call(lat, lon))
          if result && (result[:type] != "unknown" || result[:meta] == :forest_no_leaf_type)
            return result
          end

          # Step 2: nearby fallback — reuses the open connection (~200-500ms)
          nearby = run_overpass_on(http, uri, NEARBY_OQL.call(lat, lon))
          if nearby && (nearby[:type] != "unknown" || nearby[:meta] == :forest_no_leaf_type)
            nearby[:source] = nearby[:source]&.sub("osm", "osm_nearby") || "osm_nearby"
            return nearby
          end

          # Both returned unknown — return whatever we got
          return result || nearby
        end
      rescue Net::OpenTimeout, Net::ReadTimeout, StandardError => e
        Rails.logger.warn "Overpass #{base_url} failed: #{e.message}"
        next
      end
    end

    nil  # All servers failed
  end

  # Execute a single Overpass query on an already-open HTTP connection.
  def self.run_overpass_on(http, uri, oql)
    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data("data" => oql)
    response = http.request(request)
    return nil unless response.is_a?(Net::HTTPSuccess)

    data = JSON.parse(response.body)
    parse_overpass_elements(data["elements"] || [])
  rescue StandardError => e
    Rails.logger.warn "Overpass query failed: #{e.message}"
    nil
  end

  # Parse Overpass is_in() elements with priority ordering.
  # Priority: water > forest > orchard > grassland > scrub > farmland > park
  def self.parse_overpass_elements(elements)
    return unknown_result("none") if elements.empty?

    categories = { forest: [], grassland: [], orchard: [], scrubland: [],
                   farmland: [], park: [], water: [], other: [] }

    elements.each do |e|
      tags = e["tags"] || {}
      landuse = tags["landuse"]
      natural = tags["natural"]
      leisure = tags["leisure"]
      waterway = tags["waterway"]
      water = tags["water"]

      # Water tags (waterway, water=lake/reservoir, natural=water)
      if waterway || water
        categories[:water] << e
        next
      end

      tag_val = landuse || natural || leisure
      next if tag_val && IGNORE_TAGS.include?(tag_val)

      # Check if it's a water type in TERRAIN_MAP or WATER_TYPES
      if tag_val && WATER_TYPES.include?(tag_val)
        categories[:water] << e
        next
      end

      cat = TERRAIN_MAP[tag_val]
      if cat
        categories[cat] << e
      elsif leisure && %w[park garden nature_reserve].include?(leisure)
        categories[:park] << e
      elsif tag_val
        categories[:other] << e
      end
    end

    # 1. Water — highest priority (user is on water, not land)
    if categories[:water].any?
      return terrain_result("water", "osm")
    end

    # 2. Forest — try to determine leaf type
    if categories[:forest].any?
      leaf_types = categories[:forest].map { |e| e.dig("tags", "leaf_type") }.compact
      if leaf_types.include?("broadleaved")
        return terrain_result("deciduous", "osm")
      elsif leaf_types.include?("needleleaved")
        return terrain_result("coniferous", "osm")
      elsif leaf_types.include?("mixed")
        return terrain_result("mixed", "osm")
      else
        return { type: "unknown", label_en: "Forest (type unknown)",
                 label_ro: "Pădure (tip neidentificat)",
                 source: "osm_partial", meta: :forest_no_leaf_type }
      end
    end

    # 3-7. Other terrain types
    %i[orchard grassland scrubland farmland park].each do |cat|
      if categories[cat].any?
        return terrain_result(cat.to_s, "osm")
      end
    end

    # Something found but not in our map
    if categories[:other].any?
      first = categories[:other].first["tags"] || {}
      tag = first["landuse"] || first["natural"] || first["leisure"] || "detected"
      label_en = tag.tr("_", " ").capitalize
      label_ro = OTHER_LABELS_RO[tag] || label_en
      return { type: "other", label_en: label_en, label_ro: label_ro, source: "osm" }
    end

    unknown_result("none")
  end

  # ── Nominatim: reverse geocode (FALLBACK) ────────────────────────────
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
      return nil
    end

    data = JSON.parse(response.body)
    parse_nominatim_response(data)
  rescue Net::OpenTimeout, Net::ReadTimeout, StandardError => e
    Rails.logger.warn "Nominatim error: #{e.message}"
    nil
  end

  # Nominatim classes that imply an urban/built environment.
  # If we see one of these, the user is in a city — not in nature.
  URBAN_CLASSES = Set.new(%w[
    building highway shop amenity office tourism craft
    man_made railway aeroway power
  ]).freeze

  URBAN_PLACE_TYPES = Set.new(%w[
    city town suburb quarter neighbourhood borough village hamlet
  ]).freeze

  def self.parse_nominatim_response(data)
    return nil if data.nil? || data.empty? || data["error"]

    osm_class = data["class"].to_s
    osm_type = data["type"].to_s

    if osm_class == "waterway" || WATER_TYPES.include?(osm_type)
      return terrain_result("water", "nominatim")
    end

    cat = TERRAIN_MAP[osm_type]
    if cat
      if cat == :forest
        return { type: "unknown", label_en: "Forest (type unknown)",
                 label_ro: "Pădure (tip neidentificat)",
                 source: "nominatim", meta: :forest_no_leaf_type }
      end
      return terrain_result(cat.to_s, "nominatim")
    end

    if osm_class == "leisure" && %w[park garden nature_reserve].include?(osm_type)
      return terrain_result("park", "nominatim")
    end

    # Detect urban areas — buildings, roads, shops, etc. mean the user
    # is in a city/town. Many Romanian cities (Constanța, Brașov suburbs, etc.)
    # lack explicit landuse=residential polygons in OSM, so Overpass finds nothing.
    # Nominatim still returns the nearest building or road though.
    if URBAN_CLASSES.include?(osm_class) || (osm_class == "place" && URBAN_PLACE_TYPES.include?(osm_type))
      return { type: "residential", label_en: "Residential area",
               label_ro: "Zonă rezidențială", source: "nominatim" }
    end

    nil  # Not terrain-relevant — return nil so orchestrator falls through
  end

  # ── Helpers ──────────────────────────────────────────────────────────

  def self.unknown_result(source)
    { type: "unknown", label_en: "Unknown terrain", label_ro: "Teren nedetectat", source: source }
  end

  def self.terrain_result(type, source)
    labels = TERRAIN_LABELS[type.to_sym]
    if labels
      { type: type, label_en: labels[:en], label_ro: labels[:ro], source: source }
    else
      label_en = type.tr("_", " ").capitalize
      label_ro = OTHER_LABELS_RO[type] || label_en
      { type: type, label_en: label_en, label_ro: label_ro, source: source }
    end
  end

  def self.elevation_guess(elevation)
    band = ELEVATION_BANDS.find { |b| b[:range].include?(elevation) }
    return nil unless band
    { type: band[:type], label_en: band[:label_en], label_ro: band[:label_ro], source: "elevation" }
  end
end
