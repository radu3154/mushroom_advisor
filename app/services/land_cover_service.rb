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

    is_in_result = nil
    nominatim_result = nil

    # Step 1: Run is_in() and Nominatim in parallel
    t_is_in     = Thread.new { is_in_result    = query_overpass_is_in(lat, lon) }
    t_nominatim = Thread.new { nominatim_result = query_nominatim(lat, lon) }

    t_is_in.join
    t_nominatim.join

    # If is_in() found something definitive, use it immediately
    if is_in_result && (is_in_result[:type] != "unknown" || is_in_result[:meta] == :forest_no_leaf_type)
      store_cache(lat, lon, is_in_result)
      return is_in_result
    end

    # Step 2: is_in() returned unknown — try nearby features fallback.
    # Nominatim already finished (ran in parallel), so this adds minimal time.
    nearby_result = query_overpass_nearby(lat, lon)
    if nearby_result && (nearby_result[:type] != "unknown" || nearby_result[:meta] == :forest_no_leaf_type)
      nearby_result[:source] = nearby_result[:source]&.sub("osm", "osm_nearby") || "osm_nearby"
      store_cache(lat, lon, nearby_result)
      return nearby_result
    end

    # Step 3: Fall back to Nominatim or unknown
    result = if nominatim_result && (nominatim_result[:type] != "unknown" || nominatim_result[:meta] == :forest_no_leaf_type)
               nominatim_result
             else
               is_in_result || nearby_result || nominatim_result || unknown_result("none")
             end

    store_cache(lat, lon, result)
    result
  end

  # ── Overpass: is_in() — fast point-in-polygon check (~200-500ms) ──────
  def self.query_overpass_is_in(lat, lon)
    query = <<~OQL
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
    run_overpass_query(query)
  end

  # ── Overpass: nearby features fallback (~300-800ms) ──────────────────
  # Only called when is_in() returned unknown. Searches ways and relations
  # within 150m for landuse/natural tags. Catches unmapped polygon gaps
  # common in rural Romania.
  def self.query_overpass_nearby(lat, lon)
    query = <<~OQL
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
    run_overpass_query(query)
  end

  # Run an Overpass query against available servers, parse elements.
  def self.run_overpass_query(query)
    OVERPASS_URLS.each do |base_url|
      begin
        uri = URI.parse(base_url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.open_timeout = 2
        http.read_timeout = 3

        request = Net::HTTP::Post.new(uri.request_uri)
        request.set_form_data("data" => query)

        response = http.request(request)
        next unless response.is_a?(Net::HTTPSuccess)

        data = JSON.parse(response.body)
        elements = data["elements"] || []
        return parse_overpass_elements(elements)
      rescue Net::OpenTimeout, Net::ReadTimeout, StandardError => e
        Rails.logger.warn "Overpass #{base_url} failed: #{e.message}"
        next
      end
    end

    nil  # All servers failed
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
