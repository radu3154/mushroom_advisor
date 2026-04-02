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

  # Helper: build a Nominatim-style response hash
  def nominatim(osm_class, osm_type, name = "Test Feature")
    { "class" => osm_class, "type" => osm_type, "display_name" => name,
      "lat" => "47.0", "lon" => "27.0", "place_id" => 12345 }
  end

  # ── parse_nominatim_response — water detection ──────────────────────

  def test_natural_water_detected
    result = LandCoverService.send(:parse_nominatim_response, nominatim("natural", "water"))
    assert_equal "water", result[:type]
    assert_equal "Water", result[:label_en]
    assert_equal "Apă", result[:label_ro]
  end

  def test_lake_detected
    result = LandCoverService.send(:parse_nominatim_response, nominatim("natural", "lake"))
    assert_equal "water", result[:type]
  end

  def test_reservoir_detected
    result = LandCoverService.send(:parse_nominatim_response, nominatim("landuse", "reservoir"))
    assert_equal "water", result[:type]
  end

  def test_sea_detected
    result = LandCoverService.send(:parse_nominatim_response, nominatim("natural", "sea"))
    assert_equal "water", result[:type]
  end

  def test_bay_detected
    result = LandCoverService.send(:parse_nominatim_response, nominatim("natural", "bay"))
    assert_equal "water", result[:type]
  end

  def test_waterway_river_detected
    result = LandCoverService.send(:parse_nominatim_response, nominatim("waterway", "river"))
    assert_equal "water", result[:type]
  end

  def test_waterway_stream_detected
    result = LandCoverService.send(:parse_nominatim_response, nominatim("waterway", "stream"))
    assert_equal "water", result[:type]
  end

  def test_waterway_canal_detected
    result = LandCoverService.send(:parse_nominatim_response, nominatim("waterway", "canal"))
    assert_equal "water", result[:type]
  end

  def test_pond_detected
    result = LandCoverService.send(:parse_nominatim_response, nominatim("natural", "pond"))
    assert_equal "water", result[:type]
  end

  # ── parse_nominatim_response — forest detection ──────────────────────

  def test_forest_from_landuse
    result = LandCoverService.send(:parse_nominatim_response, nominatim("landuse", "forest"))
    assert_equal :forest_no_leaf_type, result[:meta],
      "Forest should be flagged for elevation refinement since Nominatim doesn't provide leaf type"
  end

  def test_wood_from_natural
    result = LandCoverService.send(:parse_nominatim_response, nominatim("natural", "wood"))
    assert_equal :forest_no_leaf_type, result[:meta]
  end

  # ── parse_nominatim_response — grassland ─────────────────────────────

  def test_meadow_from_landuse
    result = LandCoverService.send(:parse_nominatim_response, nominatim("landuse", "meadow"))
    assert_equal "grassland", result[:type]
    assert_equal "Meadow", result[:label_en]
    assert_equal "Pajiște", result[:label_ro]
  end

  def test_grassland_from_natural
    result = LandCoverService.send(:parse_nominatim_response, nominatim("natural", "grassland"))
    assert_equal "grassland", result[:type]
  end

  def test_pasture
    result = LandCoverService.send(:parse_nominatim_response, nominatim("landuse", "pasture"))
    assert_equal "grassland", result[:type]
  end

  def test_grass
    result = LandCoverService.send(:parse_nominatim_response, nominatim("landuse", "grass"))
    assert_equal "grassland", result[:type]
  end

  def test_heath
    result = LandCoverService.send(:parse_nominatim_response, nominatim("natural", "heath"))
    assert_equal "grassland", result[:type]
  end

  # ── parse_nominatim_response — farmland & orchard ────────────────────

  def test_orchard
    result = LandCoverService.send(:parse_nominatim_response, nominatim("landuse", "orchard"))
    assert_equal "orchard", result[:type]
    assert_equal "Orchard", result[:label_en]
  end

  def test_farmland
    result = LandCoverService.send(:parse_nominatim_response, nominatim("landuse", "farmland"))
    assert_equal "farmland", result[:type]
  end

  def test_vineyard
    result = LandCoverService.send(:parse_nominatim_response, nominatim("landuse", "vineyard"))
    assert_equal "farmland", result[:type]
  end

  # ── parse_nominatim_response — scrubland ─────────────────────────────

  def test_scrub
    result = LandCoverService.send(:parse_nominatim_response, nominatim("natural", "scrub"))
    assert_equal "scrubland", result[:type]
  end

  # ── parse_nominatim_response — parks ─────────────────────────────────

  def test_park_from_leisure
    result = LandCoverService.send(:parse_nominatim_response, nominatim("leisure", "park"))
    assert_equal "park", result[:type]
    assert_equal "Park", result[:label_en]
  end

  def test_nature_reserve_maps_to_park
    result = LandCoverService.send(:parse_nominatim_response, nominatim("leisure", "nature_reserve"))
    assert_equal "park", result[:type]
  end

  def test_garden_maps_to_park
    result = LandCoverService.send(:parse_nominatim_response, nominatim("leisure", "garden"))
    assert_equal "park", result[:type]
  end

  # ── parse_nominatim_response — unknown / errors ──────────────────────

  def test_residential_returns_unknown
    result = LandCoverService.send(:parse_nominatim_response, nominatim("place", "city"))
    assert_equal "unknown", result[:type]
  end

  def test_highway_returns_unknown
    result = LandCoverService.send(:parse_nominatim_response, nominatim("highway", "residential"))
    assert_equal "unknown", result[:type]
  end

  def test_nil_response
    result = LandCoverService.send(:parse_nominatim_response, nil)
    assert_equal "unknown", result[:type]
  end

  def test_empty_response
    result = LandCoverService.send(:parse_nominatim_response, {})
    assert_equal "unknown", result[:type]
  end

  def test_error_response
    result = LandCoverService.send(:parse_nominatim_response, { "error" => "Unable to geocode" })
    assert_equal "unknown", result[:type]
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
    result = { type: "grassland", label_en: "Meadow", label_ro: "Pajiște", source: "nominatim" }
    refined = LandCoverService.refine_with_elevation(result, 1900)
    assert_equal "grassland", refined[:type]
    assert_equal "Alpine meadow", refined[:label_en]
    assert_equal "nominatim+elevation", refined[:source]
  end

  def test_grassland_stays_meadow_at_low_elevation
    result = { type: "grassland", label_en: "Meadow", label_ro: "Pajiște", source: "nominatim" }
    refined = LandCoverService.refine_with_elevation(result, 600)
    assert_equal "grassland", refined[:type]
    assert_equal "Meadow", refined[:label_en]
  end

  def test_forest_no_leaf_type_resolved_by_elevation_700m
    result = { type: "unknown", label_en: "Forest (type unknown)", label_ro: "Pădure (tip neidentificat)", source: "nominatim", meta: :forest_no_leaf_type }
    refined = LandCoverService.refine_with_elevation(result, 700)
    assert_equal "deciduous", refined[:type]
  end

  def test_forest_no_leaf_type_resolved_by_elevation_1500m
    result = { type: "unknown", label_en: "Forest (type unknown)", label_ro: "Pădure (tip neidentificat)", source: "nominatim", meta: :forest_no_leaf_type }
    refined = LandCoverService.refine_with_elevation(result, 1500)
    assert_equal "coniferous", refined[:type]
  end

  def test_forest_no_leaf_type_lowland_defaults_to_deciduous
    result = { type: "unknown", label_en: "Forest (type unknown)", label_ro: "Pădure (tip neidentificat)", source: "nominatim", meta: :forest_no_leaf_type }
    refined = LandCoverService.refine_with_elevation(result, 200)
    assert_equal "deciduous", refined[:type]
    assert_equal "nominatim_default", refined[:source]
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

  # ── Open water (nothing from Nominatim + sea-level elevation) ────────

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

  # ── Real-world scenarios ─────────────────────────────────────────────

  def test_lake_ciric_iasi
    # Nominatim returns natural=water for a point on Lake Ciric
    result = LandCoverService.send(:parse_nominatim_response,
      nominatim("natural", "water", "Lacul Ciric, Iași"))
    assert_equal "water", result[:type]
  end

  def test_black_sea_open_water
    # For open sea, Nominatim might return nothing or an error → elevation fallback
    result = LandCoverService.send(:parse_nominatim_response, { "error" => "Unable to geocode" })
    assert_equal "unknown", result[:type]
    # Then elevation refinement kicks in (sea level = 0m)
    refined = LandCoverService.refine_with_elevation(result, 0)
    assert_equal "water", refined[:type]
  end

  def test_rasnov_forest_at_650m
    # Nominatim returns forest for Râșnov area → needs elevation for leaf type
    result = LandCoverService.send(:parse_nominatim_response,
      nominatim("landuse", "forest", "Râșnov, Brașov"))
    assert_equal :forest_no_leaf_type, result[:meta]

    refined = LandCoverService.refine_with_elevation(result, 650)
    assert_equal "deciduous", refined[:type],
      "Râșnov at 650m should resolve to deciduous forest"
  end

  def test_bucegi_alpine_meadow
    # Nominatim returns grassland for a high-altitude point
    result = LandCoverService.send(:parse_nominatim_response,
      nominatim("natural", "grassland", "Bucegi, Brașov"))
    assert_equal "grassland", result[:type]

    # Detect with elevation should upgrade to alpine
    refined = LandCoverService.refine_with_elevation(result, 2100)
    assert_equal "Alpine meadow", refined[:label_en]
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
