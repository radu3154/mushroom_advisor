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

  # ── parse_overpass_elements ──────────────────────────────────────────

  def test_deciduous_forest
    elements = [{ "tags" => { "landuse" => "forest", "leaf_type" => "broadleaved" } }]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "deciduous", result[:type]
    assert_equal "Deciduous forest", result[:label_en]
    assert_equal "Pădure de foioase", result[:label_ro]
  end

  def test_coniferous_forest
    elements = [{ "tags" => { "natural" => "wood", "leaf_type" => "needleleaved" } }]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "coniferous", result[:type]
  end

  def test_mixed_forest
    elements = [{ "tags" => { "landuse" => "forest", "leaf_type" => "mixed" } }]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "mixed", result[:type]
    assert_equal "Mixed forest", result[:label_en]
  end

  def test_forest_without_leaf_type_flags_for_elevation
    elements = [{ "tags" => { "landuse" => "forest" } }]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal :forest_no_leaf_type, result[:meta]
  end

  def test_meadow_from_landuse
    elements = [{ "tags" => { "landuse" => "meadow" } }]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "grassland", result[:type]
    assert_equal "Meadow", result[:label_en]
    assert_equal "Pajiște", result[:label_ro]
  end

  def test_grassland_from_natural
    elements = [{ "tags" => { "natural" => "grassland" } }]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "grassland", result[:type]
  end

  def test_pasture
    elements = [{ "tags" => { "landuse" => "pasture" } }]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "grassland", result[:type]
  end

  def test_orchard
    elements = [{ "tags" => { "landuse" => "orchard" } }]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "orchard", result[:type]
    assert_equal "Orchard", result[:label_en]
  end

  def test_farmland
    elements = [{ "tags" => { "landuse" => "farmland" } }]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "farmland", result[:type]
  end

  def test_vineyard_maps_to_farmland
    elements = [{ "tags" => { "landuse" => "vineyard" } }]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "farmland", result[:type]
  end

  def test_scrubland
    elements = [{ "tags" => { "natural" => "scrub" } }]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "scrubland", result[:type]
  end

  def test_park_from_leisure
    elements = [{ "tags" => { "leisure" => "park" } }]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "park", result[:type]
    assert_equal "Park", result[:label_en]
  end

  def test_nature_reserve_maps_to_park
    elements = [{ "tags" => { "leisure" => "nature_reserve" } }]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "park", result[:type]
  end

  def test_empty_elements_returns_unknown
    result = LandCoverService.send(:parse_overpass_elements, [])
    assert_equal "unknown", result[:type]
    assert_equal "Unknown terrain", result[:label_en]
  end

  # ── IGNORE_TAGS: geographic features that aren't land cover ──────────

  def test_mountain_range_ignored
    elements = [{ "tags" => { "natural" => "mountain_range" } }]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "unknown", result[:type],
      "mountain_range should be ignored, not classified as terrain"
  end

  def test_ridge_ignored
    elements = [{ "tags" => { "natural" => "ridge" } }]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "unknown", result[:type]
  end

  def test_peak_ignored
    elements = [{ "tags" => { "natural" => "peak" } }]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "unknown", result[:type]
  end

  def test_mountain_range_ignored_when_real_terrain_also_present
    elements = [
      { "tags" => { "natural" => "mountain_range" } },
      { "tags" => { "landuse" => "forest", "leaf_type" => "broadleaved" } }
    ]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "deciduous", result[:type],
      "Real forest terrain should win over ignored mountain_range"
  end

  def test_mountain_range_with_meadow
    elements = [
      { "tags" => { "natural" => "mountain_range" } },
      { "tags" => { "landuse" => "meadow" } }
    ]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "grassland", result[:type],
      "Real meadow should win, mountain_range should be ignored"
  end

  # ── Priority ordering ────────────────────────────────────────────────

  def test_forest_beats_grassland
    elements = [
      { "tags" => { "landuse" => "meadow" } },
      { "tags" => { "landuse" => "forest", "leaf_type" => "broadleaved" } }
    ]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "deciduous", result[:type],
      "Forest should have higher priority than grassland"
  end

  def test_orchard_beats_grassland
    elements = [
      { "tags" => { "natural" => "grassland" } },
      { "tags" => { "landuse" => "orchard" } }
    ]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "orchard", result[:type]
  end

  def test_grassland_beats_farmland
    elements = [
      { "tags" => { "landuse" => "farmland" } },
      { "tags" => { "landuse" => "meadow" } }
    ]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "grassland", result[:type]
  end

  # ── elevation_guess ──────────────────────────────────────────────────

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
    assert_equal "Deciduous forest", result[:label_en]
  end

  def test_lowland_returns_nil
    result = LandCoverService.send(:elevation_guess, 200)
    assert_nil result, "Below 400m should return nil (no guess possible)"
  end

  # ── refine_with_elevation ────────────────────────────────────────────

  def test_grassland_refined_to_alpine_at_high_elevation
    result = { type: "grassland", label_en: "Meadow", label_ro: "Pajiște", source: "osm" }
    refined = LandCoverService.refine_with_elevation(result, 1900)
    assert_equal "grassland", refined[:type]
    assert_equal "Alpine meadow", refined[:label_en]
    assert_equal "osm+elevation", refined[:source]
  end

  def test_grassland_stays_meadow_at_low_elevation
    result = { type: "grassland", label_en: "Meadow", label_ro: "Pajiște", source: "osm" }
    refined = LandCoverService.refine_with_elevation(result, 600)
    assert_equal "grassland", refined[:type]
    assert_equal "Meadow", refined[:label_en]
  end

  def test_forest_no_leaf_type_resolved_by_elevation_700m
    result = { type: "unknown", label_en: "Forest (type unknown)", label_ro: "Pădure (tip neidentificat)", source: "osm_partial", meta: :forest_no_leaf_type }
    refined = LandCoverService.refine_with_elevation(result, 700)
    assert_equal "deciduous", refined[:type]
  end

  def test_forest_no_leaf_type_resolved_by_elevation_1500m
    result = { type: "unknown", label_en: "Forest (type unknown)", label_ro: "Pădure (tip neidentificat)", source: "osm_partial", meta: :forest_no_leaf_type }
    refined = LandCoverService.refine_with_elevation(result, 1500)
    assert_equal "coniferous", refined[:type]
  end

  def test_forest_no_leaf_type_lowland_defaults_to_deciduous
    result = { type: "unknown", label_en: "Forest (type unknown)", label_ro: "Pădure (tip neidentificat)", source: "osm_partial", meta: :forest_no_leaf_type }
    refined = LandCoverService.refine_with_elevation(result, 200)
    assert_equal "deciduous", refined[:type]
    assert_equal "osm_default", refined[:source]
  end

  def test_unknown_at_high_elevation_gets_guess
    result = { type: "unknown", label_en: "Unknown terrain", label_ro: "Teren nedetectat", source: "none" }
    refined = LandCoverService.refine_with_elevation(result, 1200)
    assert_equal "mixed", refined[:type]
  end

  def test_unknown_at_low_elevation_stays_unknown
    result = { type: "unknown", label_en: "Unknown terrain", label_ro: "Teren nedetectat", source: "none" }
    refined = LandCoverService.refine_with_elevation(result, 200)
    assert_equal "unknown", refined[:type]
  end

  # ── Râșnov scenario (the actual bug) ────────────────────────────────

  def test_rasnov_mountain_range_only_falls_to_elevation_guess
    # Overpass returns mountain_range (ignored) → unknown → elevation 650m → deciduous
    elements = [{ "tags" => { "natural" => "mountain_range", "name" => "Carpathians" } }]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "unknown", result[:type], "mountain_range should be ignored"

    # Then refine with elevation (~650m for Râșnov)
    refined = LandCoverService.refine_with_elevation(result, 650)
    assert_equal "deciduous", refined[:type],
      "Râșnov at 650m should resolve to deciduous forest, not 'Mountain range'"
  end

  def test_rasnov_with_forest_and_mountain_range
    # Overpass returns both mountain_range AND a real forest tag
    elements = [
      { "tags" => { "natural" => "mountain_range", "name" => "Southern Carpathians" } },
      { "tags" => { "landuse" => "forest", "leaf_type" => "broadleaved" } }
    ]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "deciduous", result[:type],
      "Real forest should be detected, mountain_range ignored"
  end

  # ── Water detection ───────────────────────────────────────────────────

  def test_water_from_natural
    elements = [{ "tags" => { "natural" => "water" } }]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "water", result[:type]
    assert_equal "Water", result[:label_en]
    assert_equal "Apă", result[:label_ro]
  end

  def test_lake_maps_to_water
    elements = [{ "tags" => { "natural" => "lake" } }]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "water", result[:type]
  end

  def test_reservoir_maps_to_water
    elements = [{ "tags" => { "landuse" => "reservoir" } }]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "water", result[:type]
  end

  def test_sea_maps_to_water
    elements = [{ "tags" => { "natural" => "sea" } }]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "water", result[:type]
    assert_equal "Water", result[:label_en]
  end

  def test_waterway_river_maps_to_water
    elements = [{ "tags" => { "waterway" => "river", "name" => "Bahlui" } }]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "water", result[:type]
  end

  def test_waterway_lake_maps_to_water
    elements = [{ "tags" => { "waterway" => "lake" } }]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "water", result[:type]
  end

  def test_water_tag_lake_maps_to_water
    elements = [{ "tags" => { "water" => "lake", "name" => "Lacul Ciric" } }]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "water", result[:type],
      "water=lake tag should be detected as water"
  end

  def test_water_tag_reservoir_maps_to_water
    elements = [{ "tags" => { "water" => "reservoir" } }]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "water", result[:type]
  end

  def test_bay_maps_to_water
    elements = [{ "tags" => { "natural" => "bay" } }]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "water", result[:type]
  end

  def test_forest_beats_water
    elements = [
      { "tags" => { "natural" => "water" } },
      { "tags" => { "landuse" => "forest", "leaf_type" => "broadleaved" } }
    ]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "deciduous", result[:type],
      "Real forest should have priority over water"
  end

  def test_meadow_beats_water
    elements = [
      { "tags" => { "natural" => "water" } },
      { "tags" => { "landuse" => "meadow" } }
    ]
    result = LandCoverService.send(:parse_overpass_elements, elements)
    assert_equal "grassland", result[:type],
      "Real meadow should have priority over water"
  end

  # ── Open water (nothing from Overpass + sea-level elevation) ──────────

  def test_open_sea_detected_by_zero_elevation
    result = { type: "unknown", label_en: "Unknown terrain", label_ro: "Teren nedetectat", source: "none" }
    refined = LandCoverService.refine_with_elevation(result, 0)
    assert_equal "water", refined[:type]
    assert_equal "Water", refined[:label_en]
  end

  def test_open_sea_detected_by_negative_elevation
    result = { type: "unknown", label_en: "Unknown terrain", label_ro: "Teren nedetectat", source: "none" }
    refined = LandCoverService.refine_with_elevation(result, -5)
    assert_equal "water", refined[:type]
  end

  def test_low_land_not_misclassified_as_water
    result = { type: "unknown", label_en: "Unknown terrain", label_ro: "Teren nedetectat", source: "none" }
    refined = LandCoverService.refine_with_elevation(result, 15)
    # 15m is low land, not water — should stay unknown (below 400m threshold)
    assert_equal "unknown", refined[:type]
  end

  # ── Cache tests ──────────────────────────────────────────────────────

  def test_cache_key_rounds_to_2_decimals
    key1 = LandCoverService.cache_key(45.591, 25.462)
    key2 = LandCoverService.cache_key(45.594, 25.464)
    assert_equal key1, key2, "Coords within ~1km should share cache key"
  end

  def test_cache_key_differs_for_distant_coords
    key1 = LandCoverService.cache_key(45.59, 25.46)
    key2 = LandCoverService.cache_key(45.61, 25.48)
    refute_equal key1, key2
  end
end
