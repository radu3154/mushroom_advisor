require "net/http"
require "json"
require "uri"

class WeatherService
  # Single endpoint — past_days gives us history, no need for the archive API.
  # Old approach: 2 parallel calls (forecast + archive) = 2 TCP+SSL handshakes.
  # New approach: 1 call with past_days=10 = 1 handshake, half the latency.
  OPEN_METEO_URL = "https://api.open-meteo.com/v1/forecast".freeze

  class WeatherError < StandardError; end

  # ── In-memory cache ──────────────────────────────────────────────────
  # Weather doesn't change fast enough to justify re-fetching for every
  # request at the same spot. 5-minute TTL, 2-decimal key (~1.1km).
  @weather_cache = {}
  @cache_mutex = Mutex.new
  CACHE_TTL = 300  # 5 minutes

  def self.cache_key(lat, lon)
    "#{lat.round(2)},#{lon.round(2)}"
  end

  def self.cached_weather(lat, lon)
    key = cache_key(lat, lon)
    @cache_mutex.synchronize do
      entry = @weather_cache[key]
      if entry && (Time.now - entry[:at]) < CACHE_TTL
        entry[:data]
      else
        @weather_cache.delete(key) if entry  # expired
        nil
      end
    end
  end

  def self.store_cache(lat, lon, data)
    key = cache_key(lat, lon)
    @cache_mutex.synchronize do
      # Evict oldest if cache is too big
      if @weather_cache.size >= 500
        oldest_key = @weather_cache.min_by { |_, v| v[:at] }&.first
        @weather_cache.delete(oldest_key) if oldest_key
      end
      @weather_cache[key] = { data: data, at: Time.now }
    end
  end

  # temp_window: number of days to average for temperature (species-specific).
  #   Morels (7): soil temperature proxy — mycelium integrates warmth over ~20 days.
  #   Boletus (5): moisture matters more, but 5-day captures post-rain cooling.
  #   Chanterelle (7): fruiting correlates with temps 1-2 weeks prior.
  # Defaults to 7 if not provided.
  def fetch_for_location(lat:, lon:, temp_window: 7)
    # Check cache first (shared across instances via class-level cache)
    cached = self.class.cached_weather(lat, lon)
    if cached
      # Re-process with the requested temp_window (species-specific)
      return build_result(cached[:current], cached[:daily], temp_window)
    end

    # Single API call: current conditions + 10 days of daily history.
    # past_days=10 tells the forecast API to include 10 days of history.
    # forecast_days=1 includes today (needed for current conditions).
    data = fetch_weather(lat, lon)

    current = extract_current(data)
    daily = data["daily"] || {}

    # Cache the raw API response for reuse
    self.class.store_cache(lat, lon, { current: current, daily: daily })

    build_result(current, daily, temp_window)
  rescue => e
    raise WeatherError, "Failed to fetch weather: #{e.message}"
  end

  private

  def fetch_weather(lat, lon)
    url = "#{OPEN_METEO_URL}?latitude=#{lat}&longitude=#{lon}" \
          "&current=temperature_2m,relative_humidity_2m,weather_code" \
          "&daily=rain_sum,temperature_2m_mean" \
          "&past_days=10" \
          "&forecast_days=1" \
          "&timezone=auto"

    uri = URI.parse(url)
    Rails.logger.info("WeatherService: #{url}") if defined?(Rails)

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true,
                               open_timeout: 3, read_timeout: 3) do |http|
      http.request(Net::HTTP::Get.new(uri.request_uri))
    end

    unless response.is_a?(Net::HTTPSuccess)
      raise WeatherError, "API returned #{response.code}: #{response.body}"
    end

    JSON.parse(response.body)
  end

  def extract_current(data)
    current = data["current"] || {}
    {
      temp: current["temperature_2m"],
      humidity: current["relative_humidity_2m"],
      description: weather_code_to_text(current["weather_code"]),
      elevation: data["elevation"]
    }
  end

  def build_result(current, daily, temp_window)
    temp_data = extract_temp(daily, current, temp_window)
    rain_data = extract_rain(daily)

    {
      avg_temp: temp_data[:avg].round(1),
      total_rain_7d: rain_data[:total_7d].round(1),
      days_since_rain: rain_data[:days_since],
      current_month: Time.now.month,
      elevation: current[:elevation],
      raw: {
        current_temp: current[:temp],
        description: current[:description],
        humidity: current[:humidity],
        rain_daily: rain_data[:daily].last(7)
      }
    }
  end

  def extract_rain(daily)
    dates = daily["time"] || []
    rains = daily["rain_sum"] || []

    all_entries = dates.zip(rains).map { |d, r| { date: d, rain_mm: r || 0 } }

    # Today (last entry from forecast_days=1) has incomplete rain_sum — but if
    # it already shows meaningful rain (>= 0.5 mm) we keep it, otherwise the
    # user sees "dry" on a day it actually rained.  When the value is still
    # near-zero we drop it to avoid counting a day with no rain yet.
    today = all_entries.last
    if all_entries.size > 1 && today && today[:rain_mm] < 0.5
      past_entries = all_entries[0...-1]  # drop today — no significant rain yet
    else
      past_entries = all_entries            # keep today — rain already recorded
    end

    last_7 = past_entries.last(7)
    total_7d = last_7.sum { |d| d[:rain_mm] }

    days_since = 0
    past_entries.reverse.each do |d|
      break if d[:rain_mm] >= 1.0
      days_since += 1
    end

    {
      total_7d: total_7d,
      days_since: [days_since, 0].max,
      daily: past_entries
    }
  end

  # Species-specific temperature averaging.
  # Uses the last N days (temp_window) of daily mean temperatures — no live
  # temp blending. Mycelium doesn't respond to a warm afternoon; it integrates
  # sustained conditions over days.
  # Fallback: current live temp if daily data is missing.
  def extract_temp(daily, current, temp_window)
    temps = (daily["temperature_2m_mean"] || []).compact
    # Drop last entry (today — may be incomplete from forecast_days=1)
    temps = temps[0...-1] if temps.size > 1

    if temps.any?
      window = temps.last(temp_window)
      avg = window.sum / window.size.to_f
      { avg: avg }
    else
      { avg: current[:temp] || 10.0 }
    end
  end

  # WMO weather interpretation codes -> human text
  def weather_code_to_text(code)
    case code
    when 0 then "clear sky"
    when 1 then "mainly clear"
    when 2 then "partly cloudy"
    when 3 then "overcast"
    when 45, 48 then "foggy"
    when 51, 53, 55 then "drizzle"
    when 56, 57 then "freezing drizzle"
    when 61, 63, 65 then "rain"
    when 66, 67 then "freezing rain"
    when 71, 73, 75 then "snowfall"
    when 77 then "snow grains"
    when 80, 81, 82 then "rain showers"
    when 85, 86 then "snow showers"
    when 95 then "thunderstorm"
    when 96, 99 then "thunderstorm with hail"
    else "unknown"
    end
  end
end
