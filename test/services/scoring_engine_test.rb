require "minitest/autorun"
require "date"

# Minimal stubs
module Rails
  def self.logger
    @logger ||= Class.new { def warn(msg); end; def info(msg); end }.new
  end
end

module IconHelper
  def self.icon(name)
    "<svg>#{name}</svg>"
  end
end

require_relative "../../app/models/species"
require_relative "../../app/services/scoring_engine"

class ScoringEngineTest < Minitest::Test

  # Helper to build weather data
  def weather(temp: 12, rain: 20, days_since: 4, month: 4, elevation: 500)
    {
      avg_temp: temp,
      total_rain_7d: rain,
      days_since_rain: days_since,
      current_month: month,
      elevation: elevation,
      raw: { current_temp: temp, description: "clear sky", humidity: 70, rain_daily: [] }
    }
  end

  # ── Basic scoring (4 factors, no habitat) ───────────────────────────

  def test_morel_peak_conditions_scores_high
    w = weather(temp: 12, rain: 20, days_since: 4, month: 4)
    result = ScoringEngine.new("morel", w, lang: "en").call
    assert result[:score] >= 70, "Morel in ideal conditions should score >= 70, got #{result[:score]}"
    assert %w[excellent good].include?(result[:tier]),
      "Morel peak conditions should be excellent or good, got #{result[:tier]}"
  end

  def test_morel_out_of_season
    w = weather(temp: 12, rain: 20, days_since: 4, month: 8)
    result = ScoringEngine.new("morel", w, lang: "en").call
    assert_equal 0, result[:score]
    assert_equal "out-of-season", result[:tier]
    assert result[:out_of_season]
  end

  def test_boletus_in_season
    w = weather(temp: 17, rain: 30, days_since: 7, month: 8)
    result = ScoringEngine.new("boletus", w, lang: "en").call
    assert result[:score] >= 70, "Boletus in ideal conditions should score high, got #{result[:score]}"
  end

  def test_chanterelle_in_season
    w = weather(temp: 20, rain: 35, days_since: 3, month: 7)
    result = ScoringEngine.new("chanterelle", w, lang: "en").call
    assert result[:score] >= 70, "Chanterelle in ideal conditions should score high, got #{result[:score]}"
  end

  def test_no_habitat_in_breakdown
    w = weather(temp: 12, rain: 20, days_since: 4, month: 4)
    result = ScoringEngine.new("morel", w, lang: "en").call
    refute result[:breakdown].key?(:habitat), "Breakdown should not contain habitat"
    assert_equal %i[season temperature rain timing], result[:breakdown].keys
  end

  def test_max_score_is_100
    w = weather(temp: 12, rain: 20, days_since: 4, month: 4)
    result = ScoringEngine.new("morel", w, lang: "en").call
    assert result[:score] <= 100, "Score should not exceed 100, got #{result[:score]}"
  end

  # ── Temperature effects ─────────────────────────────────────────────

  def test_too_cold_kills_score
    w = weather(temp: 0, rain: 20, days_since: 4, month: 4)
    result = ScoringEngine.new("morel", w, lang: "en").call
    assert_equal 0, result[:score], "Temperature below abs_min should zero out total"
  end

  def test_too_hot_kills_score
    w = weather(temp: 35, rain: 20, days_since: 4, month: 4)
    result = ScoringEngine.new("morel", w, lang: "en").call
    assert_equal 0, result[:score], "Temperature above abs_max should zero out total"
  end

  def test_marginal_temp_reduces_score
    w_ideal = weather(temp: 12, rain: 20, days_since: 4, month: 4)
    w_marginal = weather(temp: 5, rain: 20, days_since: 4, month: 4)
    score_ideal = ScoringEngine.new("morel", w_ideal, lang: "en").call[:score]
    score_marginal = ScoringEngine.new("morel", w_marginal, lang: "en").call[:score]
    assert score_ideal > score_marginal, "Ideal temp should score higher than marginal"
  end

  # ── Water skip ──────────────────────────────────────────────────────

  def test_water_terrain_scores_zero
    w = weather(temp: 12, rain: 20, days_since: 4, month: 4)
    lc = { type: "water", label_en: "Water", label_ro: "Apă", source: "nominatim" }
    result = ScoringEngine.new("morel", w, lang: "en", land_cover: lc).call
    assert_equal 0, result[:score]
    assert_equal "skip", result[:tier]
    assert result[:on_water]
  end

  def test_water_terrain_romanian
    w = weather(temp: 12, rain: 20, days_since: 4, month: 4)
    lc = { type: "water", label_en: "Water", label_ro: "Apă", source: "nominatim" }
    result = ScoringEngine.new("morel", w, lang: "ro", land_cover: lc).call
    assert_equal 0, result[:score]
    assert_includes result[:explanation], "apă"
  end

  def test_water_applies_to_all_species
    w = weather(temp: 17, rain: 30, days_since: 7, month: 8)
    lc = { type: "water", label_en: "Water", label_ro: "Apă", source: "nominatim" }
    Species.keys.each do |key|
      result = ScoringEngine.new(key, w, lang: "en", land_cover: lc).call
      assert_equal 0, result[:score], "#{key} on water should score 0"
      assert result[:on_water], "#{key} should flag on_water"
    end
  end

  # ── Urban skip ───────────────────────────────────────────────────────

  def test_residential_terrain_scores_zero
    w = weather(temp: 12, rain: 20, days_since: 4, month: 4)
    lc = { type: "residential", label_en: "Residential", label_ro: "Zonă rezidențială", source: "osm" }
    result = ScoringEngine.new("morel", w, lang: "en", land_cover: lc).call
    assert_equal 0, result[:score]
    assert_equal "skip", result[:tier]
    assert result[:on_urban]
  end

  def test_industrial_terrain_scores_zero
    w = weather(temp: 17, rain: 30, days_since: 7, month: 8)
    lc = { type: "industrial", label_en: "Industrial", label_ro: "Zonă industrială", source: "osm" }
    result = ScoringEngine.new("boletus", w, lang: "en", land_cover: lc).call
    assert_equal 0, result[:score]
    assert result[:on_urban]
  end

  def test_urban_skip_romanian_message
    w = weather(temp: 12, rain: 20, days_since: 4, month: 4)
    lc = { type: "residential", label_en: "Residential", label_ro: "Zonă rezidențială", source: "osm" }
    result = ScoringEngine.new("morel", w, lang: "ro", land_cover: lc).call
    assert_equal "EVITĂ", result[:label]
    assert_includes result[:explanation], "zonă rezidențială"
  end

  def test_urban_applies_to_all_species
    w = weather(temp: 17, rain: 30, days_since: 7, month: 7)
    lc = { type: "commercial", label_en: "Commercial", label_ro: "Zonă comercială", source: "osm" }
    Species.keys.each do |key|
      result = ScoringEngine.new(key, w, lang: "en", land_cover: lc).call
      assert_equal 0, result[:score], "#{key} on commercial should score 0"
      assert result[:on_urban], "#{key} should flag on_urban"
    end
  end

  # ── Terrain match (for Check Terrain button) ───────────────────────

  def test_terrain_match_ideal
    assert_equal :ideal, ScoringEngine.terrain_match("morel", "deciduous")
  end

  def test_terrain_match_partial
    assert_equal :partial, ScoringEngine.terrain_match("morel", "mixed")
  end

  def test_terrain_match_bad
    assert_equal :bad, ScoringEngine.terrain_match("morel", "coniferous")
  end

  def test_terrain_match_unknown
    assert_equal :unknown, ScoringEngine.terrain_match("morel", "other")
  end

  # ── Romanian locale ─────────────────────────────────────────────────

  def test_romanian_labels
    w = weather(temp: 12, rain: 20, days_since: 4, month: 4)
    result = ScoringEngine.new("morel", w, lang: "ro").call
    assert %w[EXCELENT BINE ACCEPTABIL SLAB EVITĂ].include?(result[:label]),
      "Romanian label should be one of the RO labels, got #{result[:label]}"
  end

  def test_romanian_out_of_season
    w = weather(month: 12)
    result = ScoringEngine.new("morel", w, lang: "ro").call
    assert_equal "ÎN AFARA SEZONULUI", result[:label]
  end

  # ── Edge cases ──────────────────────────────────────────────────────

  def test_all_species_can_be_scored
    Species.keys.each do |key|
      w = weather(temp: 15, rain: 25, days_since: 5, month: 7)
      result = ScoringEngine.new(key, w, lang: "en").call
      assert result[:score].is_a?(Integer), "#{key} score should be integer"
      assert result[:score] >= 0 && result[:score] <= 100, "#{key} score out of range: #{result[:score]}"
      assert result[:tier].is_a?(String), "#{key} should have a tier"
    end
  end

  def test_unknown_species_raises
    assert_raises(ArgumentError) do
      ScoringEngine.new("unicorn", weather, lang: "en")
    end
  end

  def test_zero_rain_reduces_score
    w_good = weather(temp: 12, rain: 20, days_since: 4, month: 4)
    w_dry = weather(temp: 12, rain: 0, days_since: 15, month: 4)
    score_good = ScoringEngine.new("morel", w_good, lang: "en").call[:score]
    score_dry = ScoringEngine.new("morel", w_dry, lang: "en").call[:score]
    assert score_good > score_dry, "Good rain should score higher than no rain"
    assert_equal 0, ScoringEngine.new("morel", w_dry, lang: "en").call[:breakdown][:rain]
  end

  # ── Best time logic ─────────────────────────────────────────────────

  def test_best_time_in_sweet_spot
    w = weather(temp: 12, rain: 20, days_since: 4, month: 4)
    result = ScoringEngine.new("morel", w, lang: "en").call
    assert_includes result[:best_time], "sweet spot" if result[:best_time]
  end

  def test_best_time_wait_for_rain
    w = weather(temp: 12, rain: 20, days_since: 15, month: 4)
    result = ScoringEngine.new("morel", w, lang: "en").call
    assert_includes result[:best_time], "wait" if result[:best_time]
  end

  # ── Tips (merged habitat + tips) ────────────────────────────────────

  def test_tips_returned_in_result
    w = weather(temp: 12, rain: 20, days_since: 4, month: 4)
    result = ScoringEngine.new("morel", w, lang: "en").call
    assert result[:tips].is_a?(Array), "Tips should be an array"
    assert result[:tips].size >= 5, "Merged tips should have at least 5 entries"
    refute result.key?(:habitat), "Result should not contain :habitat key"
  end

  def test_tips_no_duplicate_burn_sites
    w = weather(temp: 12, rain: 20, days_since: 4, month: 4)
    result = ScoringEngine.new("morel", w, lang: "en").call
    burn_tips = result[:tips].select { |t| t.downcase.include?("burn") }
    assert_equal 1, burn_tips.size, "Should have exactly one burn-site tip, got #{burn_tips.size}"
  end

  # ── Additional edge cases ──────────────────────────────────────────

  def test_score_never_exceeds_100_any_species_any_conditions
    # Brute force: sweep through conditions to catch overflow
    Species.keys.each do |key|
      species = Species.find(key)
      species[:season_months].each do |month|
        [0, 5, 10, 15, 20, 25, 30, 35].each do |temp|
          [0, 5, 15, 25, 40, 60].each do |rain|
            [0, 1, 3, 5, 7, 10, 15].each do |days|
              w = weather(temp: temp, rain: rain, days_since: days, month: month)
              result = ScoringEngine.new(key, w, lang: "en").call
              assert result[:score] >= 0 && result[:score] <= 100,
                "#{key} temp=#{temp} rain=#{rain} days=#{days} month=#{month}: score=#{result[:score]} out of range"
            end
          end
        end
      end
    end
  end

  def test_score_breakdown_sums_to_total_or_zero
    Species.keys.each do |key|
      w = weather(temp: 12, rain: 20, days_since: 4, month: Species.find(key)[:season_months].first)
      result = ScoringEngine.new(key, w, lang: "en").call
      bd = result[:breakdown]
      sum = bd[:season] + bd[:temperature] + bd[:rain] + bd[:timing]
      # Total equals sum, OR total is 0 when hard-killed by abs range
      assert result[:score] == sum || result[:score] == 0,
        "#{key}: breakdown sum=#{sum} but score=#{result[:score]}"
    end
  end

  def test_no_land_cover_does_not_crash
    # Controller calls ScoringEngine without land_cover — should work fine
    w = weather(temp: 12, rain: 20, days_since: 4, month: 4)
    result = ScoringEngine.new("morel", w, lang: "en").call
    assert result[:score] >= 0, "Should score without land_cover"
    refute result[:on_water], "Should not flag on_water without land_cover"
    refute result[:on_urban], "Should not flag on_urban without land_cover"
  end

  def test_default_land_cover_is_unknown
    w = weather(temp: 12, rain: 20, days_since: 4, month: 4)
    # land_cover defaults to { type: "unknown" } — should NOT trigger water or urban
    result = ScoringEngine.new("morel", w, lang: "en").call
    assert result[:score] > 0, "unknown land_cover should not zero-out score"
  end

  def test_terrain_match_nil_species
    assert_equal :unknown, ScoringEngine.terrain_match("nonexistent", "deciduous")
  end

  def test_terrain_match_nil_terrain
    assert_equal :unknown, ScoringEngine.terrain_match("morel", nil)
  end

  def test_all_urban_types_trigger_skip
    w = weather(temp: 12, rain: 20, days_since: 4, month: 4)
    ScoringEngine::URBAN_TYPES.each do |urban_type|
      lc = { type: urban_type, label_en: urban_type, label_ro: urban_type, source: "osm" }
      result = ScoringEngine.new("morel", w, lang: "en", land_cover: lc).call
      assert_equal 0, result[:score], "Urban type '#{urban_type}' should score 0"
      assert result[:on_urban], "Urban type '#{urban_type}' should flag on_urban"
    end
  end

  def test_explanation_has_four_parts
    w = weather(temp: 12, rain: 20, days_since: 4, month: 4)
    result = ScoringEngine.new("morel", w, lang: "en").call
    parts = result[:explanation].split(" · ")
    assert_equal 4, parts.size, "Explanation should have 4 parts separated by ·, got #{parts.size}"
  end

  def test_explanation_ro_has_four_parts
    w = weather(temp: 12, rain: 20, days_since: 4, month: 4)
    result = ScoringEngine.new("morel", w, lang: "ro").call
    parts = result[:explanation].split(" · ")
    assert_equal 4, parts.size, "RO explanation should have 4 parts"
  end

  def test_best_time_nil_when_out_of_season
    w = weather(temp: 12, rain: 20, days_since: 4, month: 12)
    result = ScoringEngine.new("morel", w, lang: "en").call
    # Out of season has season_window_text as best_time
    assert result[:best_time].include?("Wait") || result[:best_time].nil? || result[:best_time].include?("Așteaptă"),
      "Out of season best_time should say 'Wait for...', got #{result[:best_time]}"
  end

  def test_boundary_temp_at_ideal_min
    # Value exactly at ideal_min boundary
    w = weather(temp: 8, rain: 20, days_since: 4, month: 4)  # morel ideal_min=8
    result = ScoringEngine.new("morel", w, lang: "en").call
    assert result[:breakdown][:temperature] >= 24,
      "Temp at ideal_min should score high (floor=24), got #{result[:breakdown][:temperature]}"
  end

  def test_boundary_temp_at_abs_min
    # Value exactly at abs_min boundary — should score 1
    w = weather(temp: 4, rain: 20, days_since: 4, month: 4)  # morel abs_min=4
    result = ScoringEngine.new("morel", w, lang: "en").call
    assert_equal 1, result[:breakdown][:temperature],
      "Temp at abs_min should score exactly 1, got #{result[:breakdown][:temperature]}"
  end

  def test_boundary_temp_just_below_abs_min
    # Value below abs_min — should score 0
    w = weather(temp: 3, rain: 20, days_since: 4, month: 4)  # morel abs_min=4
    result = ScoringEngine.new("morel", w, lang: "en").call
    assert_equal 0, result[:breakdown][:temperature],
      "Temp below abs_min should score 0, got #{result[:breakdown][:temperature]}"
  end

  def test_zero_rain_with_zero_days_since
    # Edge: no rain ever, days_since=0 (impossible in real life but test boundary)
    w = weather(temp: 12, rain: 0, days_since: 0, month: 4)
    result = ScoringEngine.new("morel", w, lang: "en").call
    assert result[:score] >= 0, "Should handle zero rain + zero days gracefully"
  end

  # ══════════════════════════════════════════════════════════════════════
  # Oyster mushroom (Pleurotus ostreatus) — species-specific tests
  # ══════════════════════════════════════════════════════════════════════

  def test_oyster_exists_in_catalog
    species = Species.find("oyster")
    assert species, "Oyster should exist in species catalog"
    assert_equal "Pleurotus ostreatus", species[:latin]
    assert_equal "Păstrăvul de fag", species[:name_ro]
  end

  def test_oyster_peak_autumn_conditions
    # Perfect oyster weather: cool October day, recent rain
    w = weather(temp: 10, rain: 25, days_since: 3, month: 10)
    result = ScoringEngine.new("oyster", w, lang: "en").call
    assert result[:score] >= 70, "Oyster in ideal October conditions should score >= 70, got #{result[:score]}"
    assert %w[excellent good].include?(result[:tier])
  end

  def test_oyster_peak_november
    w = weather(temp: 7, rain: 20, days_since: 3, month: 11)
    result = ScoringEngine.new("oyster", w, lang: "en").call
    assert result[:score] >= 60, "Oyster in November should score well, got #{result[:score]}"
  end

  def test_oyster_peak_december_cold
    # Oyster can fruit in near-freezing temps
    w = weather(temp: 2, rain: 15, days_since: 3, month: 12)
    result = ScoringEngine.new("oyster", w, lang: "en").call
    assert result[:score] > 0, "Oyster should still score > 0 at 2°C, got #{result[:score]}"
  end

  def test_oyster_out_of_season_summer
    w = weather(temp: 25, rain: 30, days_since: 3, month: 7)
    result = ScoringEngine.new("oyster", w, lang: "en").call
    assert_equal 0, result[:score]
    assert_equal "out-of-season", result[:tier]
  end

  def test_oyster_out_of_season_midsummer
    w = weather(temp: 20, rain: 30, days_since: 3, month: 8)
    result = ScoringEngine.new("oyster", w, lang: "en").call
    assert_equal 0, result[:score]
    assert_equal "out-of-season", result[:tier]
  end

  def test_oyster_in_season_spring
    w = weather(temp: 10, rain: 20, days_since: 3, month: 4)
    result = ScoringEngine.new("oyster", w, lang: "en").call
    assert result[:score] > 0, "Oyster should be in season in April, got score=#{result[:score]}"
    refute result[:out_of_season]
  end

  def test_oyster_in_season_march
    w = weather(temp: 8, rain: 15, days_since: 3, month: 3)
    result = ScoringEngine.new("oyster", w, lang: "en").call
    assert result[:score] > 0, "Oyster should be in season in March"
  end

  def test_oyster_season_months
    species = Species.find("oyster")
    assert_equal [3, 4, 5, 9, 10, 11, 12], species[:season_months]
  end

  def test_oyster_peak_months
    species = Species.find("oyster")
    assert_equal [9, 10, 11, 12], species[:peak_months]
  end

  def test_oyster_april_secondary_season_score
    # April is in season but NOT peak — should get reduced season score (~70%)
    w = weather(temp: 12, rain: 25, days_since: 3, month: 4)
    result = ScoringEngine.new("oyster", w, lang: "en").call
    assert_equal 21, result[:breakdown][:season],
      "April secondary season should score 21/30, got #{result[:breakdown][:season]}"
  end

  def test_oyster_october_peak_season_score
    # October is peak — should get full 30
    w = weather(temp: 12, rain: 25, days_since: 3, month: 10)
    result = ScoringEngine.new("oyster", w, lang: "en").call
    assert_equal 30, result[:breakdown][:season],
      "October peak season should score 30/30, got #{result[:breakdown][:season]}"
  end

  def test_oyster_peak_scores_higher_than_secondary
    w = weather(temp: 12, rain: 25, days_since: 3)
    april = ScoringEngine.new("oyster", w.merge(current_month: 4), lang: "en").call[:score]
    october = ScoringEngine.new("oyster", w.merge(current_month: 10), lang: "en").call[:score]
    assert october > april,
      "October (peak) should score higher than April (secondary): #{october} vs #{april}"
  end

  def test_oyster_secondary_season_explanation_en
    w = weather(temp: 12, rain: 25, days_since: 3, month: 4)
    result = ScoringEngine.new("oyster", w, lang: "en").call
    assert_includes result[:explanation].downcase, "secondary season"
  end

  def test_oyster_secondary_season_explanation_ro
    w = weather(temp: 12, rain: 25, days_since: 3, month: 4)
    result = ScoringEngine.new("oyster", w, lang: "ro").call
    assert_includes result[:explanation].downcase, "sezon secundar"
  end

  def test_morel_no_peak_months_all_peak
    # Morel has no peak_months — all season months should get full score
    species = Species.find("morel")
    refute species.key?(:peak_months), "Morel should not define peak_months"
    w = weather(temp: 12, rain: 20, days_since: 4, month: 4)
    result = ScoringEngine.new("morel", w, lang: "en").call
    assert_equal 30, result[:breakdown][:season],
      "Morel without peak_months should get full season score"
  end

  def test_oyster_rain_abs_max_allows_heavy_rain
    # 77.8mm should NOT hard-kill anymore (abs_max now 80)
    species = Species.find("oyster")
    assert_equal 80, species[:rain_range][:abs_max]
    w = weather(temp: 12, rain: 77, days_since: 3, month: 10)
    result = ScoringEngine.new("oyster", w, lang: "en").call
    assert result[:score] > 0,
      "77mm rain should not kill oyster score (abs_max=80), got #{result[:score]}"
  end

  def test_oyster_temp_range_includes_subfreezing
    species = Species.find("oyster")
    assert species[:temp_range][:abs_min] < 0, "Oyster abs_min should be below zero"
  end

  def test_oyster_too_warm_kills_score
    w = weather(temp: 30, rain: 20, days_since: 3, month: 10)
    result = ScoringEngine.new("oyster", w, lang: "en").call
    assert_equal 0, result[:score], "Oyster at 30°C (above abs_max 26) should score 0"
  end

  def test_oyster_warm_autumn_still_scores
    w = weather(temp: 18, rain: 20, days_since: 3, month: 9)
    result = ScoringEngine.new("oyster", w, lang: "en").call
    assert result[:score] >= 60, "Oyster at 18°C in Sept should score well, got #{result[:score]}"
  end

  def test_oyster_terrain_deciduous_ideal
    assert_equal :ideal, ScoringEngine.terrain_match("oyster", "deciduous")
  end

  def test_oyster_terrain_mixed_ideal
    assert_equal :ideal, ScoringEngine.terrain_match("oyster", "mixed")
  end

  def test_oyster_terrain_coniferous_partial
    assert_equal :partial, ScoringEngine.terrain_match("oyster", "coniferous")
  end

  def test_oyster_terrain_park_partial
    assert_equal :partial, ScoringEngine.terrain_match("oyster", "park")
  end

  def test_oyster_terrain_grassland_bad
    assert_equal :bad, ScoringEngine.terrain_match("oyster", "grassland")
  end

  def test_oyster_terrain_farmland_bad
    assert_equal :bad, ScoringEngine.terrain_match("oyster", "farmland")
  end

  def test_oyster_romanian_labels
    w = weather(temp: 10, rain: 25, days_since: 3, month: 10)
    result = ScoringEngine.new("oyster", w, lang: "ro").call
    assert %w[EXCELENT BINE ACCEPTABIL SLAB EVITĂ].include?(result[:label]),
      "Romanian label should be valid, got #{result[:label]}"
  end

  def test_oyster_romanian_out_of_season
    w = weather(temp: 20, rain: 30, days_since: 3, month: 6)
    result = ScoringEngine.new("oyster", w, lang: "ro").call
    assert_equal "ÎN AFARA SEZONULUI", result[:label]
  end

  def test_oyster_tips_returned
    w = weather(temp: 10, rain: 25, days_since: 3, month: 10)
    result = ScoringEngine.new("oyster", w, lang: "en").call
    assert result[:tips].is_a?(Array)
    assert result[:tips].size >= 5
  end

  def test_oyster_tips_ro_returned
    w = weather(temp: 10, rain: 25, days_since: 3, month: 10)
    result = ScoringEngine.new("oyster", w, lang: "ro").call
    assert result[:tips].is_a?(Array)
    assert result[:tips].size >= 5
    assert result[:tips].any? { |t| t.include?("fag") || t.include?("Fagi") },
      "Romanian tips should mention beech (fag)"
  end

  def test_oyster_has_svg
    species = Species.find("oyster")
    assert species[:svg], "Oyster should have SVG"
    assert species[:svg].include?("oyster-cap"), "SVG should contain oyster-cap elements"
  end

  def test_oyster_has_color_scheme
    species = Species.find("oyster")
    assert species[:color], "Oyster should have a color"
    assert species[:gradient_from], "Oyster should have gradient_from"
    assert species[:gradient_to], "Oyster should have gradient_to"
  end

  def test_oyster_temp_window
    species = Species.find("oyster")
    assert_equal 5, species[:temp_window], "Oyster should use 5-day temp window"
  end

  def test_oyster_explanation_four_parts
    w = weather(temp: 10, rain: 25, days_since: 3, month: 10)
    result = ScoringEngine.new("oyster", w, lang: "en").call
    parts = result[:explanation].split(" · ")
    assert_equal 4, parts.size, "Oyster explanation should have 4 parts"
  end

  def test_oyster_explanation_ro_four_parts
    w = weather(temp: 10, rain: 25, days_since: 3, month: 10)
    result = ScoringEngine.new("oyster", w, lang: "ro").call
    parts = result[:explanation].split(" · ")
    assert_equal 4, parts.size, "Oyster RO explanation should have 4 parts"
  end

  def test_oyster_terrain_scrubland_partial
    assert_equal :partial, ScoringEngine.terrain_match("oyster", "scrubland"),
      "Oyster should accept scrubland as partial terrain"
  end

  # ══════════════════════════════════════════════════════════════════════
  # Bimodal season window text (oyster gap: June–August)
  # ══════════════════════════════════════════════════════════════════════

  def test_oyster_season_window_june_shows_september
    w = weather(temp: 25, rain: 30, days_since: 3, month: 6)
    result = ScoringEngine.new("oyster", w, lang: "en").call
    assert_includes result[:best_time], "September",
      "Oyster out-of-season in June should point to September, got #{result[:best_time]}"
    refute_includes result[:best_time], "March",
      "Should NOT mention March when September is closer"
  end

  def test_oyster_season_window_august_shows_september
    w = weather(temp: 25, rain: 30, days_since: 3, month: 8)
    result = ScoringEngine.new("oyster", w, lang: "en").call
    assert_includes result[:best_time], "September"
    assert_includes result[:best_time], "December"
  end

  def test_oyster_season_window_january_shows_march
    w = weather(temp: -5, rain: 10, days_since: 3, month: 1)
    result = ScoringEngine.new("oyster", w, lang: "en").call
    assert_includes result[:best_time], "March",
      "Oyster in January should point to March window, got #{result[:best_time]}"
  end

  def test_oyster_season_window_february_ro
    w = weather(temp: -5, rain: 10, days_since: 3, month: 2)
    result = ScoringEngine.new("oyster", w, lang: "ro").call
    assert_includes result[:best_time], "Martie",
      "Romanian window should say Martie, got #{result[:best_time]}"
  end

  def test_morel_season_window_contiguous
    w = weather(temp: 0, rain: 20, days_since: 3, month: 12)
    result = ScoringEngine.new("morel", w, lang: "en").call
    assert_includes result[:best_time], "March"
    assert_includes result[:best_time], "May"
  end

  # ══════════════════════════════════════════════════════════════════════
  # Data integrity: all species consistent
  # ══════════════════════════════════════════════════════════════════════

  def test_all_species_tips_match_counts
    Species.keys.each do |key|
      s = Species.find(key)
      assert_equal s[:tips].size, s[:tips_ro].size,
        "#{key}: tips (#{s[:tips].size}) and tips_ro (#{s[:tips_ro].size}) count mismatch"
    end
  end

  def test_all_species_terrain_covers_all_types
    expected = %w[deciduous coniferous mixed grassland wetland orchard scrubland farmland park water].sort
    Species.keys.each do |key|
      s = Species.find(key)
      prefs = s[:preferred_terrain]
      all = (prefs[:ideal] + prefs[:partial] + prefs[:bad]).sort
      assert_equal expected, all,
        "#{key}: terrain types missing or extra: expected #{expected}, got #{all}"
    end
  end

  def test_all_species_no_duplicate_terrain_types
    Species.keys.each do |key|
      s = Species.find(key)
      prefs = s[:preferred_terrain]
      all = prefs[:ideal] + prefs[:partial] + prefs[:bad]
      assert_equal all.size, all.uniq.size,
        "#{key}: duplicate terrain types found: #{all.select { |t| all.count(t) > 1 }.uniq}"
    end
  end

  def test_all_species_have_required_keys
    required = %i[name name_ro latin description description_ro season_months
                  temp_range rain_range delay_days temp_window preferred_terrain
                  tips tips_ro color gradient_from gradient_to svg]
    Species.keys.each do |key|
      s = Species.find(key)
      required.each do |k|
        assert s.key?(k), "#{key}: missing required key :#{k}"
      end
    end
  end

  def test_all_species_season_months_valid
    Species.keys.each do |key|
      s = Species.find(key)
      s[:season_months].each do |m|
        assert m >= 1 && m <= 12, "#{key}: invalid month #{m}"
      end
      assert_equal s[:season_months], s[:season_months].sort, "#{key}: months should be sorted"
      assert_equal s[:season_months].size, s[:season_months].uniq.size, "#{key}: duplicate months"
    end
  end

  def test_all_species_range_consistency
    Species.keys.each do |key|
      s = Species.find(key)
      %i[temp_range rain_range delay_days].each do |range_key|
        r = s[range_key]
        assert r[:abs_min] <= r[:ideal_min], "#{key} #{range_key}: abs_min > ideal_min"
        assert r[:ideal_min] <= r[:ideal_max], "#{key} #{range_key}: ideal_min > ideal_max"
        assert r[:ideal_max] <= r[:abs_max], "#{key} #{range_key}: ideal_max > abs_max"
      end
    end
  end

  # ══════════════════════════════════════════════════════════════════════
  # Scoring edge cases: float temps, negatives, boundaries
  # ══════════════════════════════════════════════════════════════════════

  def test_float_temperature_scoring
    w = weather(temp: 11.5, rain: 20, days_since: 4, month: 4)
    result = ScoringEngine.new("morel", w, lang: "en").call
    assert result[:score] > 0, "Float temp should score normally"
    assert result[:breakdown][:temperature] > 0
  end

  def test_negative_temp_oyster_scores
    # Oyster abs_min = -5, so -3 should score marginal (> 0)
    w = weather(temp: -3, rain: 15, days_since: 3, month: 12)
    result = ScoringEngine.new("oyster", w, lang: "en").call
    assert result[:breakdown][:temperature] > 0,
      "Oyster at -3°C should score marginal temp, got #{result[:breakdown][:temperature]}"
  end

  def test_negative_temp_at_abs_min_scores_one
    # Oyster abs_min = -5
    w = weather(temp: -5, rain: 15, days_since: 3, month: 12)
    result = ScoringEngine.new("oyster", w, lang: "en").call
    assert_equal 1, result[:breakdown][:temperature],
      "Temp exactly at abs_min should score 1, got #{result[:breakdown][:temperature]}"
  end

  def test_temp_at_ideal_max_boundary
    # Morel ideal_max = 15
    w = weather(temp: 15, rain: 20, days_since: 4, month: 4)
    result = ScoringEngine.new("morel", w, lang: "en").call
    assert result[:breakdown][:temperature] >= 24,
      "Temp at ideal_max should score well (floor), got #{result[:breakdown][:temperature]}"
  end

  def test_temp_at_abs_max_boundary
    # Morel abs_max = 22
    w = weather(temp: 22, rain: 20, days_since: 4, month: 4)
    result = ScoringEngine.new("morel", w, lang: "en").call
    assert_equal 1, result[:breakdown][:temperature],
      "Temp at abs_max should score 1, got #{result[:breakdown][:temperature]}"
  end

  def test_rain_zero_kills_total_when_below_abs_min
    # Morel rain abs_min = 3. Rain 0 < 3, so out of abs range, total should be 0.
    w = weather(temp: 12, rain: 0, days_since: 4, month: 4)
    result = ScoringEngine.new("morel", w, lang: "en").call
    assert_equal 0, result[:score], "Rain below abs_min should kill total score"
  end

  def test_extreme_rain_kills_total
    # Morel rain abs_max = 55. Rain 100 > 55.
    w = weather(temp: 12, rain: 100, days_since: 4, month: 4)
    result = ScoringEngine.new("morel", w, lang: "en").call
    assert_equal 0, result[:score], "Rain above abs_max should kill total"
  end

  def test_chanterelle_delay_ideal_equals_abs_min
    # Chanterelle: delay abs_min=2, ideal_min=2. days_since=1 should score 0 timing
    s = Species.find("chanterelle")
    assert_equal s[:delay_days][:abs_min], s[:delay_days][:ideal_min],
      "Test precondition: chanterelle abs_min should equal ideal_min for timing"
    w = weather(temp: 20, rain: 35, days_since: 1, month: 7)
    result = ScoringEngine.new("chanterelle", w, lang: "en").call
    assert_equal 0, result[:breakdown][:timing],
      "1 day when abs_min=ideal_min=2 should score 0 timing"
  end

  def test_best_time_before_sweet_spot
    # days_since = 0, morel ideal_min = 3, ideal_max = 5
    w = weather(temp: 12, rain: 20, days_since: 0, month: 4)
    result = ScoringEngine.new("morel", w, lang: "en").call
    if result[:best_time]
      assert_includes result[:best_time], "3",
        "Should say 'in 3-5 days' when days_since=0"
    end
  end

  def test_best_time_past_sweet_spot
    w = weather(temp: 12, rain: 20, days_since: 12, month: 4)
    result = ScoringEngine.new("morel", w, lang: "en").call
    if result[:best_time]
      assert_includes result[:best_time], "wait",
        "Past sweet spot should say wait for rain"
    end
  end

  def test_explanation_too_cold_text
    w = weather(temp: 2, rain: 20, days_since: 4, month: 4)
    result = ScoringEngine.new("morel", w, lang: "en").call
    assert_includes result[:explanation].downcase, "cold",
      "Below-ideal temp explanation should mention cold"
  end

  def test_explanation_too_warm_text
    w = weather(temp: 20, rain: 20, days_since: 4, month: 4)
    result = ScoringEngine.new("morel", w, lang: "en").call
    assert_includes result[:explanation].downcase, "warm",
      "Above-ideal temp explanation should mention warm"
  end

  def test_explanation_too_dry_text
    w = weather(temp: 12, rain: 5, days_since: 4, month: 4)
    result = ScoringEngine.new("morel", w, lang: "en").call
    assert_includes result[:explanation].downcase, "dry",
      "Below-ideal rain explanation should mention dry"
  end

  def test_lang_fallback_to_english
    w = weather(temp: 12, rain: 20, days_since: 4, month: 4)
    result = ScoringEngine.new("morel", w, lang: "fr").call
    assert result[:label].is_a?(String), "Unknown lang should fall back to English"
    assert result[:score] >= 0
  end
end
