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
      "time"     => %w[2026-04-01 2026-04-02 2026-04-03 2026-04-04],
      "rain_sum" => [5.0, 3.0, 0.0, 0.2]  # today = 0.2 (< 0.5 threshold)
    }
    result = call_extract_rain(daily)
    # Should drop April 4 (today), only use April 1-3
    assert_equal 3, result[:daily].size
    assert_equal "2026-04-03", result[:daily].last[:date]
    assert_in_delta 8.0, result[:total_7d], 0.01  # 5 + 3 + 0
  end

  def test_keeps_today_when_significant_rain
    daily = {
      "time"     => %w[2026-04-01 2026-04-02 2026-04-03 2026-04-04],
      "rain_sum" => [0.0, 0.0, 0.0, 6.5]  # today = 6.5 (>= 0.5)
    }
    result = call_extract_rain(daily)
    # Should keep April 4 — it rained today!
    assert_equal 4, result[:daily].size
    assert_equal "2026-04-04", result[:daily].last[:date]
    assert_in_delta 6.5, result[:total_7d], 0.01
  end

  def test_keeps_today_at_threshold
    daily = {
      "time"     => %w[2026-04-05 2026-04-06 2026-04-07 2026-04-08],
      "rain_sum" => [2.0, 0.0, 1.0, 0.5]  # today = 0.5 (exactly at threshold)
    }
    result = call_extract_rain(daily)
    assert_equal 4, result[:daily].size
    assert_in_delta 3.5, result[:total_7d], 0.01
  end

  # ── extract_rain — days_since ──────────────────────────────────────────

  def test_days_since_rain_zero_when_rained_today
    daily = {
      "time"     => %w[2026-04-04 2026-04-05 2026-04-06 2026-04-07 2026-04-08],
      "rain_sum" => [0.0, 0.0, 0.0, 0.0, 8.0]  # only today
    }
    result = call_extract_rain(daily)
    assert_equal 0, result[:days_since]  # rained today
  end

  def test_days_since_rain_counts_dry_days
    daily = {
      "time"     => %w[2026-04-03 2026-04-04 2026-04-05 2026-04-06 2026-04-07],
      "rain_sum" => [4.0, 0.0, 0.0, 0.0, 0.1]  # today=0.1 (dropped), last real rain=Apr3
    }
    result = call_extract_rain(daily)
    # Today dropped (0.1 < 0.5), entries = Apr 3-6
    # Counting back from Apr 6: 0.0, 0.0, 0.0 then 4.0 => days_since = 3
    assert_equal 3, result[:days_since]
  end

  def test_days_since_rain_yesterday
    daily = {
      "time"     => %w[2026-04-05 2026-04-06 2026-04-07 2026-04-08],
      "rain_sum" => [0.0, 0.0, 2.5, 0.0]  # today=0 (dropped), yesterday=2.5
    }
    result = call_extract_rain(daily)
    # Entries = Apr 5-7, last entry (Apr 7) has 2.5 >= 1.0
    assert_equal 0, result[:days_since]
  end

  # ── extract_rain — total_7d window ─────────────────────────────────────

  def test_total_7d_sums_last_7_days
    daily = {
      "time"     => (1..11).map { |d| "2026-04-#{d.to_s.rjust(2, '0')}" },
      "rain_sum" => [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 0.1]
      # today (Apr 11) = 0.1, dropped; past = Apr 1-10; last 7 = Apr 4-10
    }
    result = call_extract_rain(daily)
    assert_in_delta(4 + 5 + 6 + 7 + 8 + 9 + 10, result[:total_7d], 0.01)  # 49
  end

  def test_total_7d_with_today_kept
    daily = {
      "time"     => (1..11).map { |d| "2026-04-#{d.to_s.rjust(2, '0')}" },
      "rain_sum" => [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 5.0]
      # today (Apr 11) = 5.0 (kept); last 7 = Apr 5-11
    }
    result = call_extract_rain(daily)
    assert_in_delta(5 + 6 + 7 + 8 + 9 + 10 + 5, result[:total_7d], 0.01)  # 50
  end

  # ── extract_rain — edge cases ──────────────────────────────────────────

  def test_single_entry_kept_as_fallback
    daily = {
      "time"     => %w[2026-04-08],
      "rain_sum" => [3.0]
    }
    result = call_extract_rain(daily)
    # Only 1 entry, can't drop it (size <= 1 guard), so it stays
    assert_equal 1, result[:daily].size
    assert_in_delta 3.0, result[:total_7d], 0.01
  end

  def test_empty_rain_data
    daily = { "time" => [], "rain_sum" => [] }
    result = call_extract_rain(daily)
    assert_equal 0, result[:daily].size
    assert_in_delta 0.0, result[:total_7d], 0.01
    assert_equal 0, result[:days_since]
  end

  def test_nil_rain_values_default_to_zero
    daily = {
      "time"     => %w[2026-04-06 2026-04-07 2026-04-08],
      "rain_sum" => [nil, 2.0, nil]  # today=nil → 0 → dropped
    }
    result = call_extract_rain(daily)
    assert_equal 2, result[:daily].size
    assert_in_delta 2.0, result[:total_7d], 0.01
  end
end
