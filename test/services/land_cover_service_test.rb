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

  def test_nominatim_road_detects_urban
    result = LandCoverService.send(:parse_nominatim_response, nominatim("highway", "residential"))
    assert_equal "residential", result[:type]
    assert_equal "nominatim", result[:source]
  end

  def test_nominatim_building_detects_urban
    result = LandCoverService.send(:parse_nominatim_response, nominatim("building", "apartments"))
    assert_equal "residential", result[:type]
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

  # All URBAN_TYPES from ScoringEngine should be detectable via Overpass
  def test_all_urban_types_detectable_via_overpass
    %w[residential industrial commercial retail construction quarry landfill
       military railway depot garages brownfield religious education].each do |tag|
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

  def test_nominatim_urban_subtype_building
    result = LandCoverService.send(:nominatim_urban_subtype, "building", "apartments")
    assert_equal "residential", result
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
end
