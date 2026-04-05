require "minitest/autorun"
require "json"

# Minimal stubs so we can test the classification logic without Rails
module Rails
  def self.logger
    @logger ||= Class.new { def warn(msg); end; def info(msg); end }.new
  end
end

require_relative "../../app/services/land_cover_service"

class LandCoverServiceTest < Minitest::Test

  # ── Helpers ──────────────────────────────────────────────────────────

  def nominatim(osm_class, osm_type, name = "Test")
    { "class" => osm_class, "type" => osm_type, "display_name" => name }
  end

  def osm(tags)
    { "tags" => tags }
  end

  # ══════════════════════════════════════════════════════════════════════
  # parse_overpass_elements — PRIMARY terrain detection
  # ══════════════════════════════════════════════════════════════════════

  # ── Water detection (highest priority) ───────────────────────────────

  def test_overpass_natural_water
    elements = [osm("natural" => "water")]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "water", result[:type]
    assert_equal "Water", result[:label_en]
    assert_equal "Apă", result[:label_ro]
  end

  def test_overpass_water_tag_lake
    elements = [osm("water" => "lake", "name" => "Lacul Ciric")]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "water", result[:type]
  end

  def test_overpass_water_tag_reservoir
    elements = [osm("water" => "reservoir")]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "water", result[:type]
  end

  def test_overpass_waterway_river
    elements = [osm("waterway" => "river", "name" => "Bahlui")]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "water", result[:type]
  end

  def test_overpass_sea
    elements = [osm("natural" => "sea")]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "water", result[:type]
  end

  def test_overpass_bay
    elements = [osm("natural" => "bay")]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "water", result[:type]
  end

  def test_overpass_water_beats_everything
    elements = [
      osm("natural" => "water"),
      osm("landuse" => "forest", "leaf_type" => "broadleaved"),
      osm("landuse" => "meadow")
    ]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "water", result[:type], "Water should have highest priority"
  end

  # ── Forest detection ─────────────────────────────────────────────────

  def test_overpass_deciduous_forest
    elements = [osm("landuse" => "forest", "leaf_type" => "broadleaved")]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "deciduous", result[:type]
    assert_equal "Deciduous forest", result[:label_en]
  end

  def test_overpass_coniferous_forest
    elements = [osm("natural" => "wood", "leaf_type" => "needleleaved")]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "coniferous", result[:type]
  end

  def test_overpass_mixed_forest
    elements = [osm("landuse" => "forest", "leaf_type" => "mixed")]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "mixed", result[:type]
  end

  def test_overpass_forest_no_leaf_type
    elements = [osm("landuse" => "forest")]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal :forest_no_leaf_type, result[:meta]
  end

  def test_overpass_forest_beats_grassland
    elements = [
      osm("landuse" => "meadow"),
      osm("landuse" => "forest", "leaf_type" => "broadleaved")
    ]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "deciduous", result[:type]
  end

  # ── Other terrain ────────────────────────────────────────────────────

  def test_overpass_meadow
    elements = [osm("landuse" => "meadow")]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "grassland", result[:type]
    assert_equal "Meadow", result[:label_en]
  end

  def test_overpass_grassland
    elements = [osm("natural" => "grassland")]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "grassland", result[:type]
  end

  def test_overpass_pasture
    elements = [osm("landuse" => "pasture")]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "grassland", result[:type]
  end

  def test_overpass_orchard
    elements = [osm("landuse" => "orchard")]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "orchard", result[:type]
  end

  def test_overpass_farmland
    elements = [osm("landuse" => "farmland")]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "farmland", result[:type]
  end

  def test_overpass_vineyard_maps_to_farmland
    elements = [osm("landuse" => "vineyard")]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "farmland", result[:type]
  end

  def test_overpass_scrub
    elements = [osm("natural" => "scrub")]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "scrubland", result[:type]
  end

  def test_overpass_park
    elements = [osm("leisure" => "park")]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "park", result[:type]
  end

  def test_overpass_nature_reserve_maps_to_park
    elements = [osm("leisure" => "nature_reserve")]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "park", result[:type]
  end

  # ── IGNORE_TAGS ──────────────────────────────────────────────────────

  def test_overpass_mountain_range_ignored
    elements = [osm("natural" => "mountain_range")]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "unknown", result[:type]
  end

  def test_overpass_mountain_range_with_real_terrain
    elements = [
      osm("natural" => "mountain_range"),
      osm("landuse" => "forest", "leaf_type" => "broadleaved")
    ]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "deciduous", result[:type]
  end

  def test_overpass_peak_ignored
    elements = [osm("natural" => "peak")]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "unknown", result[:type]
  end

  # ── Priority ordering ────────────────────────────────────────────────

  def test_overpass_orchard_beats_grassland
    elements = [
      osm("natural" => "grassland"),
      osm("landuse" => "orchard")
    ]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "orchard", result[:type]
  end

  def test_overpass_grassland_beats_farmland
    elements = [
      osm("landuse" => "farmland"),
      osm("landuse" => "meadow")
    ]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "grassland", result[:type]
  end

  def test_overpass_empty_returns_unknown
    result = LandCoverService.send(:parse_overpass_elements, [])
    assert_equal "unknown", result[:type]
  end

  # ══════════════════════════════════════════════════════════════════════
  # parse_nominatim_response — FALLBACK terrain detection
  # ══════════════════════════════════════════════════════════════════════

  def test_nominatim_water
    result = LandCoverService.send(:parse_nominatim_response, nominatim("natural", "water"))
    assert_equal "water", result[:type]
  end

  def test_nominatim_lake
    result = LandCoverService.send(:parse_nominatim_response, nominatim("natural", "lake"))
    assert_equal "water", result[:type]
  end

  def test_nominatim_waterway
    result = LandCoverService.send(:parse_nominatim_response, nominatim("waterway", "river"))
    assert_equal "water", result[:type]
  end

  def test_nominatim_forest_flags_for_elevation
    result = LandCoverService.send(:parse_nominatim_response, nominatim("landuse", "forest"))
    assert_equal :forest_no_leaf_type, result[:meta]
  end

  def test_nominatim_meadow
    result = LandCoverService.send(:parse_nominatim_response, nominatim("landuse", "meadow"))
    assert_equal "grassland", result[:type]
  end

  def test_nominatim_farmland
    result = LandCoverService.send(:parse_nominatim_response, nominatim("landuse", "farmland"))
    assert_equal "farmland", result[:type]
  end

  def test_nominatim_park
    result = LandCoverService.send(:parse_nominatim_response, nominatim("leisure", "park"))
    assert_equal "park", result[:type]
  end

  def test_nominatim_road_not_urban
    # Roads go through forests — highway class should NOT trigger urban
    result = LandCoverService.send(:parse_nominatim_response, nominatim("highway", "residential"))
    assert_nil result, "highway class should not detect as urban (roads exist in forests)"
  end

  def test_nominatim_building_not_urban
    # Buildings can be cabins, barns, ranger stations in forests
    result = LandCoverService.send(:parse_nominatim_response, nominatim("building", "apartments"))
    assert_nil result, "building class should not detect as urban (buildings exist in rural areas)"
  end

  def test_nominatim_shop_detects_commercial
    result = LandCoverService.send(:parse_nominatim_response, nominatim("shop", "supermarket"))
    assert_equal "commercial", result[:type]
    assert_equal "nominatim", result[:source]
  end

  def test_nominatim_amenity_school_detects_education
    result = LandCoverService.send(:parse_nominatim_response, nominatim("amenity", "school"))
    assert_equal "education", result[:type]
  end

  def test_nominatim_amenity_restaurant_detects_residential
    result = LandCoverService.send(:parse_nominatim_response, nominatim("amenity", "restaurant"))
    assert_equal "residential", result[:type]
  end

  def test_nominatim_office_detects_commercial
    result = LandCoverService.send(:parse_nominatim_response, nominatim("office", "company"))
    assert_equal "commercial", result[:type]
  end

  def test_nominatim_railway_detects_railway
    result = LandCoverService.send(:parse_nominatim_response, nominatim("railway", "station"))
    assert_equal "railway", result[:type]
  end

  def test_nominatim_amenity_worship_detects_religious
    result = LandCoverService.send(:parse_nominatim_response, nominatim("amenity", "place_of_worship"))
    assert_equal "religious", result[:type]
  end

  def test_nominatim_place_city_detects_urban
    result = LandCoverService.send(:parse_nominatim_response, nominatim("place", "city"))
    assert_equal "residential", result[:type]
  end

  def test_nominatim_place_village_detects_urban
    result = LandCoverService.send(:parse_nominatim_response, nominatim("place", "village"))
    assert_equal "residential", result[:type]
  end

  def test_nominatim_place_country_returns_nil
    result = LandCoverService.send(:parse_nominatim_response, nominatim("place", "country"))
    assert_nil result, "Country-level place should return nil"
  end

  def test_nominatim_error_returns_nil
    result = LandCoverService.send(:parse_nominatim_response, { "error" => "Unable to geocode" })
    assert_nil result
  end

  def test_nominatim_nil_returns_nil
    result = LandCoverService.send(:parse_nominatim_response, nil)
    assert_nil result
  end

  # ══════════════════════════════════════════════════════════════════════
  # elevation_guess
  # ══════════════════════════════════════════════════════════════════════

  def test_alpine_elevation
    result = LandCoverService.send(:elevation_guess, 2000)
    assert_equal "grassland", result[:type]
    assert_equal "Alpine meadow", result[:label_en]
  end

  def test_coniferous_elevation
    result = LandCoverService.send(:elevation_guess, 1500)
    assert_equal "coniferous", result[:type]
  end

  def test_mixed_elevation
    result = LandCoverService.send(:elevation_guess, 1200)
    assert_equal "mixed", result[:type]
  end

  def test_deciduous_elevation
    result = LandCoverService.send(:elevation_guess, 700)
    assert_equal "deciduous", result[:type]
  end

  def test_lowland_returns_nil
    result = LandCoverService.send(:elevation_guess, 200)
    assert_nil result
  end

  # ══════════════════════════════════════════════════════════════════════
  # refine_with_elevation
  # ══════════════════════════════════════════════════════════════════════

  def test_grassland_refined_to_alpine
    result = { type: "grassland", label_en: "Meadow", label_ro: "Pajiște", source: "osm" }
    refined = LandCoverService.refine_with_elevation(result, 1900)
    assert_equal "Alpine meadow", refined[:label_en]
  end

  def test_grassland_stays_at_low_elevation
    result = { type: "grassland", label_en: "Meadow", label_ro: "Pajiște", source: "osm" }
    refined = LandCoverService.refine_with_elevation(result, 600)
    assert_equal "Meadow", refined[:label_en]
  end

  def test_forest_no_leaf_type_at_700m
    result = { type: "unknown", meta: :forest_no_leaf_type, label_en: "Forest (type unknown)", label_ro: "Pădure (tip neidentificat)", source: "osm_partial" }
    refined = LandCoverService.refine_with_elevation(result, 700)
    assert_equal "deciduous", refined[:type]
  end

  def test_forest_no_leaf_type_at_1500m
    result = { type: "unknown", meta: :forest_no_leaf_type, label_en: "Forest (type unknown)", label_ro: "Pădure (tip neidentificat)", source: "osm_partial" }
    refined = LandCoverService.refine_with_elevation(result, 1500)
    assert_equal "coniferous", refined[:type]
  end

  def test_forest_no_leaf_type_lowland_defaults
    result = { type: "unknown", meta: :forest_no_leaf_type, label_en: "Forest (type unknown)", label_ro: "Pădure (tip neidentificat)", source: "osm_partial" }
    refined = LandCoverService.refine_with_elevation(result, 200)
    assert_equal "deciduous", refined[:type]
    assert_equal "osm_default", refined[:source]
  end

  def test_unknown_at_high_elevation
    result = { type: "unknown", label_en: "Unknown terrain", label_ro: "Teren nedetectat", source: "none" }
    refined = LandCoverService.refine_with_elevation(result, 1200)
    assert_equal "mixed", refined[:type]
  end

  def test_unknown_at_low_elevation_gets_farmland_hint
    result = { type: "unknown", label_en: "Unknown terrain", label_ro: "Teren nedetectat", source: "none" }
    refined = LandCoverService.refine_with_elevation(result, 200)
    assert_equal "farmland", refined[:type]
    assert_equal "elevation_hint", refined[:source]
    assert_includes refined[:label_ro], "Câmpie"
  end

  def test_sea_level_elevation_to_water
    result = { type: "unknown", label_en: "Unknown terrain", label_ro: "Teren nedetectat", source: "none" }
    refined = LandCoverService.refine_with_elevation(result, 0)
    assert_equal "water", refined[:type]
  end

  def test_negative_elevation_to_water
    result = { type: "unknown", label_en: "Unknown terrain", label_ro: "Teren nedetectat", source: "none" }
    refined = LandCoverService.refine_with_elevation(result, -5)
    assert_equal "water", refined[:type]
  end

  def test_low_land_not_water
    result = { type: "unknown", label_en: "Unknown terrain", label_ro: "Teren nedetectat", source: "none" }
    refined = LandCoverService.refine_with_elevation(result, 15)
    assert_equal "farmland", refined[:type], "Low elevation unknown should get farmland hint, not water"
    assert_equal "elevation_hint", refined[:source]
  end

  # ══════════════════════════════════════════════════════════════════════
  # Real-world scenarios
  # ══════════════════════════════════════════════════════════════════════

  def test_lake_ciric_overpass_detects_water
    elements = [osm("natural" => "water", "name" => "Lacul Ciric")]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "water", result[:type]
  end

  def test_lake_ciric_via_water_tag
    elements = [osm("water" => "lake", "name" => "Lacul Ciric")]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "water", result[:type]
  end

  def test_rasnov_mountain_range_ignored
    elements = [osm("natural" => "mountain_range", "name" => "Carpathians")]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "unknown", result[:type]
    refined = LandCoverService.refine_with_elevation(result, 650)
    assert_equal "deciduous", refined[:type]
  end

  def test_black_sea_via_elevation_fallback
    result = { type: "unknown", label_en: "Unknown terrain", label_ro: "Teren nedetectat", source: "none" }
    refined = LandCoverService.refine_with_elevation(result, 0)
    assert_equal "water", refined[:type]
  end

  # ── Overpass "other" terrain (residential, industrial, etc.) ──────────

  def test_overpass_residential_returns_actual_tag
    elements = [osm("landuse" => "residential")]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "residential", result[:type], "Should return actual tag, not 'other'"
    assert_equal "Residential", result[:label_en]
    assert_equal "Zonă rezidențială", result[:label_ro]
  end

  def test_overpass_sand_translated_to_romanian
    elements = [osm("natural" => "sand")]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "sand", result[:type], "Should return actual tag, not 'other'"
    assert_equal "Sand", result[:label_en]
    assert_equal "Nisip", result[:label_ro]
  end

  def test_overpass_quarry_translated_to_romanian
    elements = [osm("landuse" => "quarry")]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "quarry", result[:type], "Should return actual tag, not 'other'"
    assert_equal "Quarry", result[:label_en]
    assert_equal "Carieră", result[:label_ro]
  end

  def test_overpass_residential_ignored_when_real_terrain_present
    elements = [
      osm("landuse" => "residential"),
      osm("landuse" => "forest", "leaf_type" => "broadleaved")
    ]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "deciduous", result[:type],
      "Forest should win over residential"
  end

  # ── Orchestration: forest_no_leaf_type should beat Nominatim ─────────

  def test_overpass_forest_beats_nominatim_grassland
    # Overpass finds forest polygon (accurate) → type "unknown" with meta
    overpass = { type: "unknown", label_en: "Forest (type unknown)",
                 label_ro: "Pădure (tip neidentificat)",
                 source: "osm_partial", meta: :forest_no_leaf_type }
    # Nominatim returns nearest meadow (less accurate)
    nominatim = { type: "grassland", label_en: "Meadow",
                  label_ro: "Pajiște", source: "nominatim" }

    # The orchestrator should prefer Overpass forest over Nominatim grassland
    result = if overpass && (overpass[:type] != "unknown" || overpass[:meta] == :forest_no_leaf_type)
               overpass
             elsif nominatim && (nominatim[:type] != "unknown" || nominatim[:meta] == :forest_no_leaf_type)
               nominatim
             else
               overpass || nominatim
             end

    assert_equal :forest_no_leaf_type, result[:meta],
      "Overpass forest detection should beat Nominatim grassland"
  end

  # ══════════════════════════════════════════════════════════════════════
  # Overpass query parsing
  # ══════════════════════════════════════════════════════════════════════

  def test_empty_elements_returns_unknown
    # parse_overpass_elements([]) returns unknown when no elements found
    result = LandCoverService.send(:parse_overpass_elements, [])
    assert_equal "unknown", result[:type]
  end

  # ══════════════════════════════════════════════════════════════════════
  # Nearby fallback: elements from around:150 should parse identically
  # ══════════════════════════════════════════════════════════════════════

  def test_nearby_meadow_detected
    # around:150 returns way elements with tags (same format as is_in areas)
    elements = [osm("landuse" => "meadow", "name" => "Pajiște comunală")]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "grassland", result[:type]
  end

  def test_nearby_forest_detected
    elements = [osm("landuse" => "forest", "leaf_type" => "broadleaved")]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "deciduous", result[:type]
  end

  def test_nearby_water_detected
    elements = [osm("natural" => "water", "name" => "Lacul de acumulare")]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "water", result[:type]
  end

  def test_nearby_farmland_detected
    elements = [osm("landuse" => "farmland")]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "farmland", result[:type]
  end

  # ══════════════════════════════════════════════════════════════════════
  # Cache
  # ══════════════════════════════════════════════════════════════════════

  def test_cache_key_rounds_to_2_decimals
    key1 = LandCoverService.cache_key(45.591, 25.462)
    key2 = LandCoverService.cache_key(45.594, 25.464)
    assert_equal key1, key2
  end

  def test_cache_key_differs_for_distant_coords
    key1 = LandCoverService.cache_key(45.59, 25.46)
    key2 = LandCoverService.cache_key(45.61, 25.48)
    refute_equal key1, key2
  end

  # ══════════════════════════════════════════════════════════════════════
  # Edge cases — Bug regression tests
  # ══════════════════════════════════════════════════════════════════════

  # BUG 2 regression: Overpass residential must return "residential" type
  # so URBAN_TYPES check works in the controller.
  def test_overpass_residential_type_matches_urban_types
    elements = [osm("landuse" => "residential")]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    require "set"
    urban = Set.new(%w[residential industrial commercial retail construction
                       quarry landfill military railway depot garages
                       brownfield religious education])
    assert urban.include?(result[:type]),
      "Overpass residential should return type matchable by URBAN_TYPES, got '#{result[:type]}'"
  end

  def test_overpass_industrial_type_matches_urban_types
    elements = [osm("landuse" => "industrial")]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "industrial", result[:type]
  end

  def test_overpass_commercial_type_matches_urban_types
    elements = [osm("landuse" => "commercial")]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "commercial", result[:type]
  end

  def test_overpass_cemetery_returns_actual_tag
    elements = [osm("landuse" => "cemetery")]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "cemetery", result[:type]
    assert_equal "Cimitir", result[:label_ro]
  end

  # detect() edge cases
  def test_detect_nil_elevation_does_not_trigger_water
    # Stub query_terrain to return unknown
    LandCoverService.stub(:query_terrain, { type: "unknown", label_en: "Unknown terrain", label_ro: "Teren nedetectat", source: "none" }) do
      result = LandCoverService.detect(lat: 44.17, lon: 28.63, elevation: nil)
      refute_equal "water", result[:type],
        "nil elevation should NOT trigger water detection"
    end
  end

  def test_detect_elevation_zero_triggers_water
    result = LandCoverService.detect(lat: 44.0, lon: 28.0, elevation: 0)
    assert_equal "water", result[:type]
  end

  def test_detect_negative_elevation_triggers_water
    result = LandCoverService.detect(lat: 44.0, lon: 28.0, elevation: -10)
    assert_equal "water", result[:type]
  end

  def test_detect_elevation_1_does_not_trigger_water
    LandCoverService.stub(:query_terrain, { type: "unknown", label_en: "Unknown terrain", label_ro: "Teren nedetectat", source: "none" }) do
      result = LandCoverService.detect(lat: 44.17, lon: 28.63, elevation: 1)
      refute_equal "water", result[:type],
        "elevation=1 should NOT trigger water override"
    end
  end

  # Nominatim edge: empty hash
  def test_nominatim_empty_hash_returns_nil
    result = LandCoverService.send(:parse_nominatim_response, {})
    assert_nil result
  end

  # Nominatim edge: class=boundary should not be urban
  def test_nominatim_boundary_not_urban
    result = LandCoverService.send(:parse_nominatim_response, nominatim("boundary", "administrative"))
    assert_nil result, "Administrative boundaries should not be detected as urban"
  end

  # Nominatim edge: class=natural, type=tree should not match
  def test_nominatim_single_tree_returns_nil
    result = LandCoverService.send(:parse_nominatim_response, nominatim("natural", "tree"))
    assert_nil result, "A single tree is not meaningful terrain"
  end

  # Multiple Overpass elements: residential + forest → forest wins
  def test_overpass_forest_beats_residential
    elements = [
      osm("landuse" => "residential"),
      osm("landuse" => "forest", "leaf_type" => "needleleaved")
    ]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "coniferous", result[:type],
      "Forest should beat residential in priority ordering"
  end

  # All URBAN_TYPES from ScoringEngine that have landuse equivalents
  # should be detectable via Overpass. (religious/education come from
  # Nominatim sub-classification, not landuse tags.)
  def test_most_urban_types_detectable_via_overpass
    %w[residential industrial commercial retail construction quarry landfill
       military railway depot garages brownfield].each do |tag|
      elements = [osm("landuse" => tag)]
      result = LandCoverService.send(:parse_overpass_elements, elements)
      assert_equal tag, result[:type],
        "Overpass should return '#{tag}' as type for landuse=#{tag}, got '#{result[:type]}'"
    end
  end

  # terrain_result with unknown type not in TERRAIN_LABELS or OTHER_LABELS_RO
  def test_terrain_result_unknown_tag_uses_english_fallback
    result = LandCoverService.send(:terrain_result, "some_weird_tag", "osm")
    assert_equal "Some weird tag", result[:label_en]
    assert_equal "Some weird tag", result[:label_ro], "Should fall back to English when no RO translation"
  end

  # ══════════════════════════════════════════════════════════════════════
  # Wetland detection
  # ══════════════════════════════════════════════════════════════════════

  def test_overpass_wetland
    elements = [osm("natural" => "wetland")]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "wetland", result[:type]
    assert_equal "Wetland", result[:label_en]
    assert_equal "Zonă umedă", result[:label_ro]
  end

  def test_overpass_marsh_maps_to_wetland
    elements = [osm("natural" => "marsh")]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "wetland", result[:type]
  end

  def test_overpass_bog_maps_to_wetland
    elements = [osm("natural" => "bog")]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "wetland", result[:type]
  end

  def test_overpass_swamp_maps_to_wetland
    elements = [osm("natural" => "swamp")]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "wetland", result[:type]
  end

  def test_overpass_fen_maps_to_wetland
    elements = [osm("natural" => "fen")]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "wetland", result[:type]
  end

  def test_overpass_wetland_priority_between_grassland_and_scrub
    # Wetland should appear after grassland but before scrubland in priority
    elements = [
      osm("natural" => "scrub"),
      osm("natural" => "wetland")
    ]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "wetland", result[:type], "Wetland should beat scrubland in priority"
  end

  def test_overpass_grassland_beats_wetland
    elements = [
      osm("natural" => "wetland"),
      osm("landuse" => "meadow")
    ]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "grassland", result[:type], "Grassland should beat wetland in priority"
  end

  def test_nominatim_wetland
    result = LandCoverService.send(:parse_nominatim_response, nominatim("natural", "wetland"))
    assert_equal "wetland", result[:type]
    assert_equal "nominatim", result[:source]
  end

  # ══════════════════════════════════════════════════════════════════════
  # Forest genus/species inference
  # ══════════════════════════════════════════════════════════════════════

  def test_forest_genus_fagus_infers_deciduous
    elements = [osm("landuse" => "forest", "genus" => "Fagus")]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "deciduous", result[:type]
    assert_equal "osm_inferred", result[:source]
  end

  def test_forest_genus_picea_infers_coniferous
    elements = [osm("landuse" => "forest", "genus" => "Picea")]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "coniferous", result[:type]
    assert_equal "osm_inferred", result[:source]
  end

  def test_forest_species_picea_abies_infers_coniferous
    elements = [osm("landuse" => "forest", "species" => "Picea abies")]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "coniferous", result[:type]
    assert_equal "osm_inferred", result[:source]
  end

  def test_forest_mixed_genera_infers_mixed
    elements = [
      osm("landuse" => "forest", "genus" => "Fagus"),
      osm("landuse" => "forest", "genus" => "Picea")
    ]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "mixed", result[:type]
    assert_equal "osm_inferred", result[:source]
  end

  def test_forest_unknown_genus_falls_to_no_leaf_type
    elements = [osm("landuse" => "forest", "genus" => "UnknownGenus")]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal :forest_no_leaf_type, result[:meta]
  end

  def test_infer_leaf_type_broadleaved_genera
    %w[quercus fagus carpinus fraxinus acer betula tilia].each do |genus|
      elements = [osm("landuse" => "forest", "genus" => genus.capitalize)]
      result = LandCoverService.send(:infer_leaf_type_from_taxa, elements.map { |e| e })
      assert_equal "deciduous", result, "Genus #{genus} should infer deciduous"
    end
  end

  def test_infer_leaf_type_needleleaved_genera
    %w[picea abies pinus larix juniperus].each do |genus|
      elements = [osm("landuse" => "forest", "genus" => genus.capitalize)]
      result = LandCoverService.send(:infer_leaf_type_from_taxa, elements.map { |e| e })
      assert_equal "coniferous", result, "Genus #{genus} should infer coniferous"
    end
  end

  # ══════════════════════════════════════════════════════════════════════
  # Lowland elevation heuristic
  # ══════════════════════════════════════════════════════════════════════

  def test_lowland_heuristic_at_1m
    result = { type: "unknown", label_en: "Unknown terrain", label_ro: "Teren nedetectat", source: "none" }
    refined = LandCoverService.refine_with_elevation(result, 1)
    assert_equal "farmland", refined[:type]
    assert_equal "elevation_hint", refined[:source]
  end

  def test_lowland_heuristic_at_399m
    result = { type: "unknown", label_en: "Unknown terrain", label_ro: "Teren nedetectat", source: "none" }
    refined = LandCoverService.refine_with_elevation(result, 399)
    assert_equal "farmland", refined[:type]
    assert_equal "elevation_hint", refined[:source]
  end

  def test_lowland_heuristic_not_at_400m
    result = { type: "unknown", label_en: "Unknown terrain", label_ro: "Teren nedetectat", source: "none" }
    refined = LandCoverService.refine_with_elevation(result, 400)
    assert_equal "deciduous", refined[:type], "400m should use elevation_guess (deciduous), not lowland heuristic"
  end

  def test_lowland_heuristic_not_for_known_terrain
    # If terrain is already known (e.g., grassland), lowland heuristic should NOT override
    result = { type: "grassland", label_en: "Meadow", label_ro: "Pajiște", source: "osm" }
    refined = LandCoverService.refine_with_elevation(result, 100)
    assert_equal "grassland", refined[:type], "Known terrain should not be overridden by lowland heuristic"
  end

  # ══════════════════════════════════════════════════════════════════════
  # Nominatim urban sub-classification
  # ══════════════════════════════════════════════════════════════════════

  def test_nominatim_urban_subtype_shop
    result = LandCoverService.send(:nominatim_urban_subtype, "shop", "supermarket")
    assert_equal "commercial", result
  end

  def test_nominatim_urban_subtype_office
    result = LandCoverService.send(:nominatim_urban_subtype, "office", "company")
    assert_equal "commercial", result
  end

  def test_nominatim_urban_subtype_railway
    result = LandCoverService.send(:nominatim_urban_subtype, "railway", "station")
    assert_equal "railway", result
  end

  def test_nominatim_urban_subtype_amenity_school
    result = LandCoverService.send(:nominatim_urban_subtype, "amenity", "school")
    assert_equal "education", result
  end

  def test_nominatim_urban_subtype_amenity_university
    result = LandCoverService.send(:nominatim_urban_subtype, "amenity", "university")
    assert_equal "education", result
  end

  def test_nominatim_urban_subtype_amenity_worship
    result = LandCoverService.send(:nominatim_urban_subtype, "amenity", "place_of_worship")
    assert_equal "religious", result
  end

  def test_nominatim_urban_subtype_amenity_other
    result = LandCoverService.send(:nominatim_urban_subtype, "amenity", "restaurant")
    assert_equal "residential", result
  end

  def test_nominatim_urban_subtype_default_fallback
    # Classes not explicitly mapped fall back to "residential"
    result = LandCoverService.send(:nominatim_urban_subtype, "something_else", "whatever")
    assert_equal "residential", result
  end

  # ══════════════════════════════════════════════════════════════════════
  # NATURE_TYPES — urban types should NOT be in the set
  # ══════════════════════════════════════════════════════════════════════

  def test_nature_types_includes_terrain_labels
    %w[deciduous coniferous mixed grassland wetland orchard scrubland farmland park water].each do |t|
      assert LandCoverService::NATURE_TYPES.include?(t),
        "NATURE_TYPES should include '#{t}'"
    end
  end

  def test_nature_types_excludes_urban
    %w[residential industrial commercial railway education religious].each do |t|
      refute LandCoverService::NATURE_TYPES.include?(t),
        "NATURE_TYPES should NOT include '#{t}'"
    end
  end

  # Elevation boundary values
  def test_elevation_1800_is_alpine
    result = LandCoverService.send(:elevation_guess, 1800)
    assert_equal "grassland", result[:type]
    assert_equal "Alpine meadow", result[:label_en]
  end

  def test_elevation_1799_is_coniferous
    result = LandCoverService.send(:elevation_guess, 1799)
    assert_equal "coniferous", result[:type]
  end

  def test_elevation_1400_is_coniferous
    result = LandCoverService.send(:elevation_guess, 1400)
    assert_equal "coniferous", result[:type]
  end

  def test_elevation_1399_is_mixed
    result = LandCoverService.send(:elevation_guess, 1399)
    assert_equal "mixed", result[:type]
  end

  def test_elevation_400_is_deciduous
    result = LandCoverService.send(:elevation_guess, 400)
    assert_equal "deciduous", result[:type]
  end

  def test_elevation_399_returns_nil
    result = LandCoverService.send(:elevation_guess, 399)
    assert_nil result
  end

  # ══════════════════════════════════════════════════════════════════════
  # Additional edge cases — deep bug hunt
  # ══════════════════════════════════════════════════════════════════════

  # TERRAIN_MAP coverage: test all mapped tags produce valid types
  def test_terrain_map_all_tags_parseable
    LandCoverService::TERRAIN_MAP.each do |tag, category|
      elements = [osm("landuse" => tag)]
      result = LandCoverService.send(:parse_overpass_elements, elements)
      if result[:type] == "unknown" && result[:meta] != :forest_no_leaf_type
        elements = [osm("natural" => tag)]
        result = LandCoverService.send(:parse_overpass_elements, elements)
      end
      # forest/wood without leaf_type → forest_no_leaf_type (valid, pending elevation)
      valid = result[:type] != "unknown" || result[:meta] == :forest_no_leaf_type
      assert valid,
        "Tag '#{tag}' (→ #{category}) should parse to valid type, got #{result[:type]} meta=#{result[:meta]}"
    end
  end

  def test_overpass_heath_maps_to_grassland
    elements = [osm("natural" => "heath")]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "grassland", result[:type]
  end

  def test_overpass_fell_maps_to_grassland
    elements = [osm("natural" => "fell")]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "grassland", result[:type]
  end

  def test_overpass_village_green_maps_to_grassland
    elements = [osm("landuse" => "village_green")]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "grassland", result[:type]
  end

  def test_overpass_recreation_ground_maps_to_grassland
    elements = [osm("landuse" => "recreation_ground")]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "grassland", result[:type]
  end

  def test_overpass_allotments_maps_to_farmland
    elements = [osm("landuse" => "allotments")]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "farmland", result[:type]
  end

  def test_overpass_garden_maps_to_park
    elements = [osm("leisure" => "garden")]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "park", result[:type]
  end

  # Forest with BOTH leaf_type AND genus — leaf_type should win
  def test_forest_leaf_type_takes_priority_over_genus
    elements = [osm("landuse" => "forest", "leaf_type" => "broadleaved", "genus" => "Picea")]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "deciduous", result[:type],
      "leaf_type=broadleaved should win over genus=Picea"
  end

  # Multiple water + forest: water wins
  def test_water_beats_forest_even_with_leaf_type
    elements = [
      osm("landuse" => "forest", "leaf_type" => "broadleaved"),
      osm("waterway" => "stream")
    ]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "water", result[:type]
  end

  # Only IGNORE_TAGS present → unknown
  def test_only_ignored_tags_returns_unknown
    elements = [
      osm("natural" => "peak"),
      osm("natural" => "ridge"),
      osm("natural" => "mountain_range")
    ]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "unknown", result[:type]
  end

  # Tags with nil values should not crash
  def test_element_with_nil_tags_does_not_crash
    result = LandCoverService.send(:parse_overpass_elements, [{ "tags" => nil }])
    assert_equal "unknown", result[:type]
  end

  def test_element_with_empty_tags_does_not_crash
    result = LandCoverService.send(:parse_overpass_elements, [{ "tags" => {} }])
    assert_equal "unknown", result[:type]
  end

  def test_element_missing_tags_key_does_not_crash
    result = LandCoverService.send(:parse_overpass_elements, [{}])
    assert_equal "unknown", result[:type]
  end

  # Nominatim: leisure=garden should return park
  def test_nominatim_garden_is_park
    result = LandCoverService.send(:parse_nominatim_response, nominatim("leisure", "garden"))
    assert_equal "park", result[:type]
  end

  # Nominatim: leisure=nature_reserve should return park
  def test_nominatim_nature_reserve_is_park
    result = LandCoverService.send(:parse_nominatim_response, nominatim("leisure", "nature_reserve"))
    assert_equal "park", result[:type]
  end

  # Nominatim: class=aeroway → commercial
  def test_nominatim_aeroway_is_commercial
    result = LandCoverService.send(:parse_nominatim_response, nominatim("aeroway", "aerodrome"))
    assert_equal "commercial", result[:type]
  end

  # Nominatim: tourism/man_made/power should NOT detect urban
  # These exist in rural/nature areas (viewpoints, towers, power lines)
  def test_nominatim_tourism_not_urban
    result = LandCoverService.send(:parse_nominatim_response, nominatim("tourism", "hotel"))
    assert_nil result, "tourism class should not detect as urban"
  end

  def test_nominatim_man_made_not_urban
    result = LandCoverService.send(:parse_nominatim_response, nominatim("man_made", "tower"))
    assert_nil result, "man_made class should not detect as urban"
  end

  def test_nominatim_power_not_urban
    result = LandCoverService.send(:parse_nominatim_response, nominatim("power", "substation"))
    assert_nil result, "power class should not detect as urban"
  end

  def test_nominatim_highway_forest_road_not_urban
    result = LandCoverService.send(:parse_nominatim_response, nominatim("highway", "track"))
    assert_nil result, "Forest track should not detect as urban"
  end

  def test_nominatim_building_cabin_not_urban
    result = LandCoverService.send(:parse_nominatim_response, nominatim("building", "cabin"))
    assert_nil result, "Remote cabin should not detect as urban"
  end

  # Nominatim: amenity kindergarten → education
  def test_nominatim_kindergarten_detects_education
    result = LandCoverService.send(:parse_nominatim_response, nominatim("amenity", "kindergarten"))
    assert_equal "education", result[:type]
  end

  # Nominatim: amenity library → education
  def test_nominatim_library_detects_education
    result = LandCoverService.send(:parse_nominatim_response, nominatim("amenity", "library"))
    assert_equal "education", result[:type]
  end

  # Nominatim: amenity monastery → religious
  def test_nominatim_monastery_detects_religious
    result = LandCoverService.send(:parse_nominatim_response, nominatim("amenity", "monastery"))
    assert_equal "religious", result[:type]
  end

  # Cache: store and retrieve
  def test_cache_store_and_retrieve
    test_result = { type: "deciduous", label_en: "Test", label_ro: "Test", source: "test" }
    LandCoverService.store_cache(99.99, 88.88, test_result)
    cached = LandCoverService.cached_terrain(99.99, 88.88)
    assert_equal "deciduous", cached[:type]
    assert_equal "test", cached[:source]
  end

  def test_cache_miss_returns_nil
    result = LandCoverService.cached_terrain(0.01, 0.01)
    assert_nil result
  end

  # refine_with_elevation: known terrain not overridden at high elevation
  def test_known_farmland_not_overridden_at_high_elevation
    result = { type: "farmland", label_en: "Farmland", label_ro: "Teren agricol", source: "osm" }
    refined = LandCoverService.refine_with_elevation(result, 1500)
    assert_equal "farmland", refined[:type],
      "Known farmland should not be changed to coniferous by elevation"
  end

  # refine_with_elevation: nil elevation returns as-is
  def test_refine_nil_elevation_returns_result
    result = { type: "deciduous", label_en: "Deciduous forest", label_ro: "Pădure de foioase", source: "osm" }
    refined = LandCoverService.refine_with_elevation(result, nil)
    assert_equal "deciduous", refined[:type]
  end

  # WATER_TYPES completeness
  def test_water_types_all_detected_via_overpass
    %w[water lake pond reservoir basin riverbank sea bay strait river stream canal].each do |wtype|
      elements = [osm("natural" => wtype)]
      result = LandCoverService.send(:parse_overpass_elements, elements)
      assert_equal "water", result[:type],
        "WATER_TYPE '#{wtype}' should parse as water via natural tag, got #{result[:type]}"
    end
  end

  # Priority: orchard > grassland > wetland > scrubland > farmland > park
  def test_overpass_orchard_beats_wetland
    elements = [
      osm("natural" => "wetland"),
      osm("landuse" => "orchard")
    ]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "orchard", result[:type]
  end

  def test_overpass_wetland_beats_farmland
    elements = [
      osm("landuse" => "farmland"),
      osm("natural" => "wetland")
    ]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "wetland", result[:type]
  end

  def test_overpass_farmland_beats_park
    elements = [
      osm("leisure" => "park"),
      osm("landuse" => "farmland")
    ]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "farmland", result[:type]
  end

  # Multiple Nominatim place types should all be urban
  def test_nominatim_all_urban_place_types
    %w[city town suburb quarter neighbourhood borough village hamlet].each do |ptype|
      result = LandCoverService.send(:parse_nominatim_response, nominatim("place", ptype))
      assert_equal "residential", result[:type],
        "Place type '#{ptype}' should detect as residential"
    end
  end

  # ══════════════════════════════════════════════════════════════════════
  # FALSE POSITIVE REGRESSION TESTS
  # Real-world Romanian scenarios where terrain was wrongly detected
  # ══════════════════════════════════════════════════════════════════════

  # ── Nominatim false positives (roads/buildings in nature) ────────────

  def test_forest_road_not_urban
    # Nominatim finds a forest road → should NOT return "residential"
    result = LandCoverService.send(:parse_nominatim_response, nominatim("highway", "track"))
    assert_nil result
  end

  def test_mountain_pass_road_not_urban
    result = LandCoverService.send(:parse_nominatim_response, nominatim("highway", "secondary"))
    assert_nil result
  end

  def test_ranger_cabin_not_urban
    result = LandCoverService.send(:parse_nominatim_response, nominatim("building", "hut"))
    assert_nil result
  end

  def test_forest_tower_not_urban
    result = LandCoverService.send(:parse_nominatim_response, nominatim("man_made", "observation_tower"))
    assert_nil result
  end

  def test_mountain_viewpoint_not_urban
    result = LandCoverService.send(:parse_nominatim_response, nominatim("tourism", "viewpoint"))
    assert_nil result
  end

  def test_power_line_in_forest_not_urban
    result = LandCoverService.send(:parse_nominatim_response, nominatim("power", "line"))
    assert_nil result
  end

  # ── Classes that SHOULD still detect urban ──────────────────────────

  def test_nominatim_shop_still_urban
    result = LandCoverService.send(:parse_nominatim_response, nominatim("shop", "bakery"))
    assert_equal "commercial", result[:type]
  end

  def test_nominatim_office_still_urban
    result = LandCoverService.send(:parse_nominatim_response, nominatim("office", "insurance"))
    assert_equal "commercial", result[:type]
  end

  def test_nominatim_amenity_still_urban
    result = LandCoverService.send(:parse_nominatim_response, nominatim("amenity", "hospital"))
    assert_equal "residential", result[:type]
  end

  def test_nominatim_craft_still_urban
    result = LandCoverService.send(:parse_nominatim_response, nominatim("craft", "carpenter"))
    assert_equal "residential", result[:type]
  end

  def test_nominatim_place_village_still_urban
    result = LandCoverService.send(:parse_nominatim_response, nominatim("place", "village"))
    assert_equal "residential", result[:type]
  end

  # ── Elevation override for urban types ──────────────────────────────

  def test_elevation_overrides_residential_at_800m
    # Overpass says "residential" but we're at 800m → deciduous forest
    result = { type: "residential", label_en: "Residential", label_ro: "Zonă rezidențială", source: "osm" }
    refined = LandCoverService.refine_with_elevation(result, 800)
    assert_equal "deciduous", refined[:type],
      "Residential at 800m should be overridden to deciduous, got #{refined[:type]}"
    assert_equal "elevation_override", refined[:source]
  end

  def test_elevation_overrides_residential_at_1500m
    result = { type: "residential", label_en: "Residential", label_ro: "Zonă rezidențială", source: "osm" }
    refined = LandCoverService.refine_with_elevation(result, 1500)
    assert_equal "coniferous", refined[:type]
  end

  def test_elevation_does_not_override_residential_at_200m
    # 200m is lowland — residential is plausible, no elevation_guess match
    result = { type: "residential", label_en: "Residential", label_ro: "Zonă rezidențială", source: "osm" }
    refined = LandCoverService.refine_with_elevation(result, 200)
    assert_equal "residential", refined[:type],
      "Residential at 200m should stay residential (lowland town)"
  end

  def test_elevation_does_not_override_residential_at_350m
    result = { type: "residential", label_en: "Residential", label_ro: "Zonă rezidențială", source: "osm" }
    refined = LandCoverService.refine_with_elevation(result, 350)
    assert_equal "residential", refined[:type],
      "Residential at 350m should stay residential (could be a hill town)"
  end

  def test_elevation_overrides_industrial_at_600m
    result = { type: "industrial", label_en: "Industrial", label_ro: "Zonă industrială", source: "osm" }
    refined = LandCoverService.refine_with_elevation(result, 600)
    assert_equal "deciduous", refined[:type]
  end

  def test_elevation_does_not_override_nature_type
    # Nature types should NEVER be overridden by elevation
    result = { type: "grassland", label_en: "Meadow", label_ro: "Pajiște", source: "osm" }
    refined = LandCoverService.refine_with_elevation(result, 800)
    assert_equal "grassland", refined[:type],
      "Grassland should not be changed to deciduous"
  end

  # ── detect() with elevation sanity check ────────────────────────────

  def test_detect_residential_overridden_at_high_elevation
    overpass_residential = { type: "residential", label_en: "Residential",
                             label_ro: "Zonă rezidențială", source: "osm" }
    LandCoverService.stub(:query_terrain, overpass_residential) do
      result = LandCoverService.detect(lat: 46.0, lon: 25.0, elevation: 800)
      assert_equal "deciduous", result[:type],
        "Residential at 800m should be overridden by elevation"
    end
  end

  def test_detect_residential_stays_at_low_elevation
    overpass_residential = { type: "residential", label_en: "Residential",
                             label_ro: "Zonă rezidențială", source: "osm" }
    LandCoverService.stub(:query_terrain, overpass_residential) do
      result = LandCoverService.detect(lat: 44.4, lon: 26.1, elevation: 80)
      assert_equal "residential", result[:type],
        "Residential at 80m (Bucharest) should stay residential"
    end
  end

  def test_detect_residential_needs_elevation_when_nil
    overpass_residential = { type: "residential", label_en: "Residential",
                             label_ro: "Zonă rezidențială", source: "osm" }
    LandCoverService.stub(:query_terrain, overpass_residential) do
      result = LandCoverService.detect(lat: 46.0, lon: 25.0, elevation: nil)
      assert result[:needs_elevation],
        "Residential without elevation should request elevation for sanity check"
    end
  end

  def test_detect_forest_not_affected_by_elevation_check
    overpass_forest = { type: "deciduous", label_en: "Deciduous forest",
                        label_ro: "Pădure de foioase", source: "osm" }
    LandCoverService.stub(:query_terrain, overpass_forest) do
      result = LandCoverService.detect(lat: 46.0, lon: 25.0, elevation: 800)
      assert_equal "deciduous", result[:type],
        "Nature types should pass through unchanged"
    end
  end

  # ── End-to-end scenarios (orchestrator + classification) ────────────

  def test_scenario_forest_with_residential_polygon
    # Overpass is_in finds residential, but nearby finds forest → forest wins
    # (Tests the query_overpass NATURE_TYPES logic)
    elements_isin = [osm("landuse" => "residential")]
    result_isin = LandCoverService.send(:parse_overpass_elements, elements_isin)
    assert_equal "residential", result_isin[:type], "is_in sees residential"

    elements_nearby = [osm("landuse" => "forest", "leaf_type" => "broadleaved")]
    result_nearby = LandCoverService.send(:parse_overpass_elements, elements_nearby)
    assert_equal "deciduous", result_nearby[:type], "nearby finds forest"
    # In query_overpass, residential is NOT a NATURE_TYPE so nearby runs and wins
  end

  def test_scenario_nominatim_road_in_forest_fallback_to_unknown
    # Overpass finds nothing, Nominatim finds a road → should be nil (not urban)
    nom = LandCoverService.send(:parse_nominatim_response, nominatim("highway", "residential"))
    assert_nil nom, "Road should not be treated as terrain"

    # Orchestrator would then use overpass "unknown" or unknown_result
    # → elevation heuristic kicks in via detect()
  end

  def test_scenario_village_detected_correctly
    # Place=village should still correctly detect urban
    nom = LandCoverService.send(:parse_nominatim_response, nominatim("place", "village"))
    assert_equal "residential", nom[:type]
    # At 200m elevation, residential stays (no elevation override)
  end

  # ── Overpass "other" types preserved correctly ──────────────────────

  def test_overpass_urban_landuse_types_still_work
    # These are LANDUSE tags from Overpass (polygon-level), which are trustworthy
    %w[residential industrial commercial construction quarry military].each do |tag|
      elements = [osm("landuse" => tag)]
      result = LandCoverService.send(:parse_overpass_elements, elements)
      assert_equal tag, result[:type],
        "Overpass landuse=#{tag} should return '#{tag}'"
    end
  end

  # ══════════════════════════════════════════════════════════════════════
  # Mixed leaf_type inference — overlapping forest polygons
  # ══════════════════════════════════════════════════════════════════════

  def test_overlapping_broadleaved_and_needleleaved_returns_mixed
    # Two forest polygons overlap at the query point — one oak, one spruce.
    # Should detect "mixed" instead of favouring broadleaved.
    elements = [
      osm("landuse" => "forest", "leaf_type" => "broadleaved"),
      osm("natural" => "wood",   "leaf_type" => "needleleaved")
    ]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "mixed", result[:type],
      "Overlapping broadleaved + needleleaved forests should return mixed"
  end

  def test_mixed_leaf_type_still_returns_mixed
    elements = [osm("landuse" => "forest", "leaf_type" => "mixed")]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "mixed", result[:type]
  end

  def test_mixed_with_broadleaved_returns_mixed
    # A "mixed" polygon overlapping a "broadleaved" polygon → still mixed
    elements = [
      osm("landuse" => "forest", "leaf_type" => "broadleaved"),
      osm("landuse" => "forest", "leaf_type" => "mixed")
    ]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "mixed", result[:type]
  end

  def test_three_forests_broadleaved_only_returns_deciduous
    elements = [
      osm("landuse" => "forest", "leaf_type" => "broadleaved"),
      osm("natural" => "wood",   "leaf_type" => "broadleaved"),
      osm("landuse" => "forest", "leaf_type" => "broadleaved")
    ]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "deciduous", result[:type],
      "Multiple broadleaved-only forests should still return deciduous"
  end

  # ══════════════════════════════════════════════════════════════════════
  # detect() integration — grassland + elevation combinations
  # ══════════════════════════════════════════════════════════════════════

  def test_detect_grassland_at_low_elevation_stays_grassland
    # Meadow at 300m should stay grassland, NOT get elevation-overridden
    grassland = { type: "grassland", label_en: "Meadow", label_ro: "Pajiște", source: "osm" }
    LandCoverService.stub(:query_terrain, grassland) do
      result = LandCoverService.detect(lat: 46.0, lon: 25.0, elevation: 300)
      assert_equal "grassland", result[:type]
      refute result[:needs_elevation], "Low-elevation grassland should not need elevation"
    end
  end

  def test_detect_grassland_at_1200m_stays_grassland
    # Meadow at 1200m — still a real meadow, should NOT be overridden to mixed forest
    grassland = { type: "grassland", label_en: "Meadow", label_ro: "Pajiște", source: "osm" }
    LandCoverService.stub(:query_terrain, grassland) do
      result = LandCoverService.detect(lat: 45.5, lon: 24.5, elevation: 1200)
      assert_equal "grassland", result[:type]
    end
  end

  def test_detect_grassland_nil_elevation_needs_elevation
    grassland = { type: "grassland", label_en: "Meadow", label_ro: "Pajiște", source: "osm" }
    LandCoverService.stub(:query_terrain, grassland) do
      result = LandCoverService.detect(lat: 46.0, lon: 25.0, elevation: nil)
      assert_equal "grassland", result[:type]
      assert result[:needs_elevation], "Grassland with nil elevation should need elevation"
    end
  end

  def test_detect_grassland_at_1800m_becomes_alpine
    grassland = { type: "grassland", label_en: "Meadow", label_ro: "Pajiște", source: "osm" }
    LandCoverService.stub(:query_terrain, grassland) do
      result = LandCoverService.detect(lat: 45.5, lon: 24.5, elevation: 1800)
      assert_equal "grassland", result[:type]
      assert_equal "Alpine meadow", result[:label_en]
      assert_equal "Pajiște alpină", result[:label_ro]
    end
  end

  def test_detect_grassland_at_2200m_becomes_alpine
    grassland = { type: "grassland", label_en: "Meadow", label_ro: "Pajiște", source: "osm" }
    LandCoverService.stub(:query_terrain, grassland) do
      result = LandCoverService.detect(lat: 45.5, lon: 24.5, elevation: 2200)
      assert_equal "grassland", result[:type]
      assert_equal "Alpine meadow", result[:label_en]
    end
  end

  # ══════════════════════════════════════════════════════════════════════
  # detect() integration — nature types NOT affected by elevation override
  # ══════════════════════════════════════════════════════════════════════

  def test_detect_deciduous_at_1500m_not_overridden
    # A deciduous forest tagged by Overpass at 1500m is real — don't override to coniferous
    deciduous = { type: "deciduous", label_en: "Deciduous forest", label_ro: "Pădure de foioase", source: "osm" }
    LandCoverService.stub(:query_terrain, deciduous) do
      result = LandCoverService.detect(lat: 45.5, lon: 24.5, elevation: 1500)
      assert_equal "deciduous", result[:type],
        "OSM-detected deciduous should not be overridden by elevation"
    end
  end

  def test_detect_coniferous_at_500m_not_overridden
    # Coniferous plantation at low elevation is real
    coniferous = { type: "coniferous", label_en: "Coniferous forest", label_ro: "Pădure de conifere", source: "osm" }
    LandCoverService.stub(:query_terrain, coniferous) do
      result = LandCoverService.detect(lat: 45.5, lon: 24.5, elevation: 500)
      assert_equal "coniferous", result[:type],
        "OSM-detected coniferous should not be overridden by elevation"
    end
  end

  def test_detect_wetland_at_800m_not_overridden
    wetland = { type: "wetland", label_en: "Wetland", label_ro: "Zonă umedă", source: "osm" }
    LandCoverService.stub(:query_terrain, wetland) do
      result = LandCoverService.detect(lat: 45.5, lon: 24.5, elevation: 800)
      assert_equal "wetland", result[:type]
    end
  end

  def test_detect_park_not_overridden
    park = { type: "park", label_en: "Park", label_ro: "Parc", source: "osm" }
    LandCoverService.stub(:query_terrain, park) do
      result = LandCoverService.detect(lat: 45.5, lon: 24.5, elevation: 600)
      assert_equal "park", result[:type]
    end
  end

  # ══════════════════════════════════════════════════════════════════════
  # refine_with_elevation() — full integration for AJAX path
  # ══════════════════════════════════════════════════════════════════════

  def test_refine_residential_at_700m_overrides_to_deciduous
    result = { type: "residential", label_en: "Residential area",
               label_ro: "Zonă rezidențială", source: "nominatim", needs_elevation: true }
    refined = LandCoverService.refine_with_elevation(result, 700)
    assert_equal "deciduous", refined[:type]
    assert_equal "elevation_override", refined[:source]
  end

  def test_refine_residential_at_250m_stays_residential
    result = { type: "residential", label_en: "Residential area",
               label_ro: "Zonă rezidențială", source: "nominatim", needs_elevation: true }
    refined = LandCoverService.refine_with_elevation(result, 250)
    assert_equal "residential", refined[:type],
      "Low-elevation residential should stay residential"
  end

  def test_refine_unknown_at_600m_gets_deciduous
    result = { type: "unknown", label_en: "Unknown terrain",
               label_ro: "Teren nedetectat", source: "none" }
    refined = LandCoverService.refine_with_elevation(result, 600)
    assert_equal "deciduous", refined[:type]
  end

  def test_refine_unknown_at_1600m_gets_coniferous
    result = { type: "unknown", label_en: "Unknown terrain",
               label_ro: "Teren nedetectat", source: "none" }
    refined = LandCoverService.refine_with_elevation(result, 1600)
    assert_equal "coniferous", refined[:type]
  end

  def test_refine_unknown_at_2000m_gets_alpine
    result = { type: "unknown", label_en: "Unknown terrain",
               label_ro: "Teren nedetectat", source: "none" }
    refined = LandCoverService.refine_with_elevation(result, 2000)
    assert_equal "grassland", refined[:type]
    assert_equal "Alpine meadow", refined[:label_en]
  end

  def test_refine_forest_no_leaf_at_1100m_gets_mixed
    result = { type: "unknown", label_en: "Forest (type unknown)",
               label_ro: "Pădure (tip neidentificat)", source: "osm_partial",
               meta: :forest_no_leaf_type }
    refined = LandCoverService.refine_with_elevation(result, 1100)
    assert_equal "mixed", refined[:type]
  end

  def test_refine_forest_no_leaf_at_500m_gets_deciduous
    result = { type: "unknown", label_en: "Forest (type unknown)",
               label_ro: "Pădure (tip neidentificat)", source: "osm_partial",
               meta: :forest_no_leaf_type }
    refined = LandCoverService.refine_with_elevation(result, 500)
    assert_equal "deciduous", refined[:type]
  end

  def test_refine_forest_no_leaf_no_elevation_defaults_deciduous
    result = { type: "unknown", label_en: "Forest (type unknown)",
               label_ro: "Pădure (tip neidentificat)", source: "osm_partial",
               meta: :forest_no_leaf_type }
    refined = LandCoverService.refine_with_elevation(result, nil)
    assert_equal "deciduous", refined[:type]
    assert_equal "osm_default", refined[:source]
  end

  # ══════════════════════════════════════════════════════════════════════
  # Genus inference edge cases
  # ══════════════════════════════════════════════════════════════════════

  def test_genus_case_insensitive
    # OSM data can have mixed-case genus tags
    elements = [osm("landuse" => "forest", "genus" => "Fagus")]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "deciduous", result[:type]
  end

  def test_species_tag_extracts_genus_correctly
    elements = [osm("landuse" => "forest", "species" => "Abies alba")]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "coniferous", result[:type]
  end

  def test_mixed_genera_from_species_tags
    elements = [
      osm("landuse" => "forest", "species" => "Fagus sylvatica"),
      osm("natural" => "wood",   "species" => "Picea abies")
    ]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "mixed", result[:type]
  end

  # ══════════════════════════════════════════════════════════════════════
  # NATURE_TYPES consistency
  # ══════════════════════════════════════════════════════════════════════

  def test_all_terrain_map_targets_are_nature_types
    # Every category that TERRAIN_MAP maps to should be in NATURE_TYPES
    terrain_types = LandCoverService::TERRAIN_MAP.values.uniq.map(&:to_s)
    terrain_types.each do |t|
      # :forest is an intermediate → resolved to deciduous/coniferous/mixed
      next if t == "forest"
      assert LandCoverService::NATURE_TYPES.include?(t),
        "TERRAIN_MAP target '#{t}' should be in NATURE_TYPES"
    end
  end

  def test_elevation_band_types_are_nature_types
    LandCoverService::ELEVATION_BANDS.each do |band|
      assert LandCoverService::NATURE_TYPES.include?(band[:type]),
        "Elevation band type '#{band[:type]}' should be in NATURE_TYPES"
    end
  end
end
