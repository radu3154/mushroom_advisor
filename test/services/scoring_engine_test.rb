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
end
