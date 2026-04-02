require "net/http"
require "json"
require "uri"

class WeatherService
  OPEN_METEO_ARCHIVE_URL = "https://archive-api.open-meteo.com/v1/archive".freeze
  OPEN_METEO_FORECAST_URL = "https://api.open-meteo.com/v1/forecast".freeze

  class WeatherError < StandardError; end

  # temp_window: number of days to average for temperature (species-specific).
  #   Morels (7): soil temperature proxy — mycelium integrates warmth over ~20 days.
  #   Boletus (5): moisture matters more, but 5-day captures post-rain cooling.
  #   Chanterelle (7): fruiting correlates with temps 1-2 weeks prior.
  # Defaults to 7 if not provided.
  def fetch_for_location(lat:, lon:, temp_window: 7)
    # Fetch current conditions and historical data IN PARALLEL (saves ~2-3s)
    current = nil
    history = nil
    current_thread = Thread.new { current = fetch_current(lat, lon) }
    history_thread = Thread.new { history = fetch_history(lat, lon) }
    current_thread.join
    history_thread.join

    temp_data = extract_temp_from_history(history, current, temp_window)
    rain_data = extract_rain_from_history(history)

    # Elevation comes from the forecast API response
    elevation = current[:elevation]

    {
      avg_temp: temp_data[:avg].round(1),
      total_rain_7d: rain_data[:total_7d].round(1),
      days_since_rain: rain_data[:days_since],
      current_month: Time.now.month,
      elevation: elevation,
      raw: {
        current_temp: current[:temp],
        description: current[:description],
        humidity: current[:humidity],
        rain_daily: rain_data[:daily].last(7)
      }
    }
  rescue => e
    raise WeatherError, "Failed to fetch weather: #{e.message}"
  end

  private

  def fetch_json(url)
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 10
    http.read_timeout = 10

    request = Net::HTTP::Get.new(uri.request_uri)
    Rails.logger.info("Fetching: #{url}") if defined?(Rails)
    response = http.request(request)

    unless response.is_a?(Net::HTTPSuccess)
      raise WeatherError, "API returned #{response.code}: #{response.body}"
    end

    JSON.parse(response.body)
  end

  # Current weather from Open-Meteo forecast API
  def fetch_current(lat, lon)
    url = "#{OPEN_METEO_FORECAST_URL}?latitude=#{lat}&longitude=#{lon}" \
          "&current=temperature_2m,relative_humidity_2m,weather_code" \
          "&timezone=auto"

    data = fetch_json(url)
    current = data["current"] || {}

    {
      temp: current["temperature_2m"],
      humidity: current["relative_humidity_2m"],
      description: weather_code_to_text(current["weather_code"]),
      elevation: data["elevation"]
    }
  end

  # Last 10 days of daily rain and temperature from Open-Meteo archive.
  # We fetch 10 days so species with temp_window=7 get a full 7-day average,
  # and we have 3 extra for days_since_rain look-back. Rain chart shows last 7.
  def fetch_history(lat, lon)
    end_date = Date.today - 1  # archive doesn't include today
    start_date = end_date - 9  # 10 days total

    url = "#{OPEN_METEO_ARCHIVE_URL}?latitude=#{lat}&longitude=#{lon}" \
          "&start_date=#{start_date}&end_date=#{end_date}" \
          "&daily=rain_sum,temperature_2m_mean" \
          "&timezone=auto"

    fetch_json(url)
  end

  def extract_rain_from_history(history)
    dates = history.dig("daily", "time") || []
    rains = history.dig("daily", "rain_sum") || []

    daily = dates.zip(rains).map { |d, r| { date: d, rain_mm: r || 0 } }

    last_7 = daily.last(7)
    total_7d = last_7.sum { |d| d[:rain_mm] }

    days_since = 0
    daily.reverse.each do |d|
      break if d[:rain_mm] >= 1.0
      days_since += 1
    end

    {
      total_7d: total_7d,
      days_since: [days_since, 0].max,
      daily: daily
    }
  end

  # Species-specific temperature averaging.
  # Uses the last N days (temp_window) of daily mean temperatures — no live
  # temp blending. Mycelium doesn't respond to a warm afternoon; it integrates
  # sustained conditions over days. Live temp added noise and made the readings
  # too reactive for all three species.
  # Fallback: current live temp if archive data is missing.
  def extract_temp_from_history(history, current, temp_window)
    temps = history.dig("daily", "temperature_2m_mean") || []
    temps = temps.compact

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
