require "minitest/autorun"
require_relative "../../app/services/weather_service"

class WeatherServiceTest < Minitest::Test
  # ── Helper: build a WeatherService instance we can test private methods on ──
  def service
    @service ||= WeatherService.new
  end

  def call_extract_rain(daily)
    service.send(:extract_rain, daily)
  end

  # ── extract_rain — today handling ──────────────────────────────────────

  def test_drops_today_when_no_significant_rain
    daily = {
      "time"              => %w[2026-04-01 2026-04-02 2026-04-03 2026-04-04],
      "precipitation_sum" => [5.0, 3.0, 0.0, 0.2]  # today = 0.2 (< 0.5 threshold)
    }
    result = call_extract_rain(daily)
    assert_equal 3, result[:daily].size
    assert_equal "2026-04-03", result[:daily].last[:date]
    assert_in_delta 8.0, result[:total_7d], 0.01
  end

  def test_keeps_today_when_significant_rain
    daily = {
      "time"              => %w[2026-04-01 2026-04-02 2026-04-03 2026-04-04],
      "precipitation_sum" => [0.0, 0.0, 0.0, 6.5]  # today = 6.5 (>= 0.5)
    }
    result = call_extract_rain(daily)
    assert_equal 4, result[:daily].size
    assert_equal "2026-04-04", result[:daily].last[:date]
    assert_in_delta 6.5, result[:total_7d], 0.01
  end

  def test_keeps_today_at_threshold
    daily = {
      "time"              => %w[2026-04-05 2026-04-06 2026-04-07 2026-04-08],
      "precipitation_sum" => [2.0, 0.0, 1.0, 0.5]
    }
    result = call_extract_rain(daily)
    assert_equal 4, result[:daily].size
    assert_in_delta 3.5, result[:total_7d], 0.01
  end

  # ── extract_rain — days_since ──────────────────────────────────────────

  def test_days_since_rain_zero_when_rained_today
    daily = {
      "time"              => %w[2026-04-04 2026-04-05 2026-04-06 2026-04-07 2026-04-08],
      "precipitation_sum" => [0.0, 0.0, 0.0, 0.0, 8.0]
    }
    result = call_extract_rain(daily)
    assert_equal 0, result[:days_since]
  end

  def test_days_since_rain_counts_dry_days
    daily = {
      "time"              => %w[2026-04-03 2026-04-04 2026-04-05 2026-04-06 2026-04-07],
      "precipitation_sum" => [4.0, 0.0, 0.0, 0.0, 0.1]
    }
    result = call_extract_rain(daily)
    assert_equal 3, result[:days_since]
  end

  def test_days_since_rain_yesterday
    daily = {
      "time"              => %w[2026-04-05 2026-04-06 2026-04-07 2026-04-08],
      "precipitation_sum" => [0.0, 0.0, 2.5, 0.0]
    }
    result = call_extract_rain(daily)
    assert_equal 0, result[:days_since]
  end

  # ── extract_rain — total_7d window ─────────────────────────────────────

  def test_total_7d_sums_last_7_days
    daily = {
      "time"              => (1..11).map { |d| "2026-04-#{d.to_s.rjust(2, '0')}" },
      "precipitation_sum" => [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 0.1]
    }
    result = call_extract_rain(daily)
    assert_in_delta(4 + 5 + 6 + 7 + 8 + 9 + 10, result[:total_7d], 0.01)
  end

  def test_total_7d_with_today_kept
    daily = {
      "time"              => (1..11).map { |d| "2026-04-#{d.to_s.rjust(2, '0')}" },
      "precipitation_sum" => [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 5.0]
    }
    result = call_extract_rain(daily)
    assert_in_delta(5 + 6 + 7 + 8 + 9 + 10 + 5, result[:total_7d], 0.01)
  end

  # ── extract_rain — edge cases ──────────────────────────────────────────

  def test_single_entry_kept_as_fallback
    daily = {
      "time"              => %w[2026-04-08],
      "precipitation_sum" => [3.0]
    }
    result = call_extract_rain(daily)
    assert_equal 1, result[:daily].size
    assert_in_delta 3.0, result[:total_7d], 0.01
  end

  def test_empty_rain_data
    daily = { "time" => [], "precipitation_sum" => [] }
    result = call_extract_rain(daily)
    assert_equal 0, result[:daily].size
    assert_in_delta 0.0, result[:total_7d], 0.01
    assert_equal 0, result[:days_since]
  end

  def test_nil_rain_values_default_to_zero
    daily = {
      "time"              => %w[2026-04-06 2026-04-07 2026-04-08],
      "precipitation_sum" => [nil, 2.0, nil]
    }
    result = call_extract_rain(daily)
    assert_equal 2, result[:daily].size
    assert_in_delta 2.0, result[:total_7d], 0.01
  end

  # ── extract_rain — fallback to rain_sum if precipitation_sum missing ───

  def test_falls_back_to_rain_sum_key
    daily = {
      "time"     => %w[2026-04-06 2026-04-07 2026-04-08],
      "rain_sum" => [4.0, 2.0, 0.0]  # no precipitation_sum key
    }
    result = call_extract_rain(daily)
    assert_equal 2, result[:daily].size
    assert_in_delta 6.0, result[:total_7d], 0.01
  end

  def test_prefers_precipitation_sum_over_rain_sum
    daily = {
      "time"              => %w[2026-04-07 2026-04-08],
      "precipitation_sum" => [10.0, 3.0],  # includes showers
      "rain_sum"          => [5.0, 1.0]    # rain-only (lower)
    }
    result = call_extract_rain(daily)
    assert_equal 2, result[:daily].size
    assert_in_delta 13.0, result[:total_7d], 0.01  # uses precipitation_sum
  end
end
