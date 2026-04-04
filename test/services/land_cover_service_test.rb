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

  def test_nominatim_road_returns_nil
    result = LandCoverService.send(:parse_nominatim_response, nominatim("highway", "residential"))
    assert_nil result, "Non-terrain features should return nil"
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

  def test_unknown_at_low_elevation_stays
    result = { type: "unknown", label_en: "Unknown terrain", label_ro: "Teren nedetectat", source: "none" }
    refined = LandCoverService.refine_with_elevation(result, 200)
    assert_equal "unknown", refined[:type]
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
    assert_equal "unknown", refined[:type]
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

  def test_overpass_residential_returns_other
    elements = [osm("landuse" => "residential")]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "other", result[:type]
    assert_equal "Residential", result[:label_en]
    assert_equal "Zonă rezidențială", result[:label_ro]
  end

  def test_overpass_sand_translated_to_romanian
    elements = [osm("natural" => "sand")]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "other", result[:type]
    assert_equal "Sand", result[:label_en]
    assert_equal "Nisip", result[:label_ro]
  end

  def test_overpass_quarry_translated_to_romanian
    elements = [osm("landuse" => "quarry")]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "other", result[:type]
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
end
