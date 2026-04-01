require "net/http"
require "json"
require "uri"

class WeatherService
  OPEN_METEO_ARCHIVE_URL = "https://archive-api.open-meteo.com/v1/archive".freeze
  OPEN_METEO_FORECAST_URL = "https://api.open-meteo.com/v1/forecast".freeze

  class WeatherError < StandardError; end

  def fetch_for_location(lat:, lon:)
    # Current conditions from Open-Meteo forecast API (free, no key)
    current = fetch_current(lat, lon)

    # Historical rain + temp from Open-Meteo archive API (free, no key)
    history = fetch_history(lat, lon)

    temp_data = extract_temp_from_history(history, current)
    rain_data = extract_rain_from_history(history)

    {
      avg_temp: temp_data[:avg].round(1),
      total_rain_7d: rain_data[:total_7d].round(1),
      days_since_rain: rain_data[:days_since],
      current_month: Time.now.month,
      raw: {
        current_temp: current[:temp],
        description: current[:description],
        humidity: current[:humidity],
        rain_daily: rain_data[:daily]
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
      description: weather_code_to_text(current["weather_code"])
    }
  end

  # Last 10 days of daily rain and temperature from Open-Meteo archive
  def fetch_history(lat, lon)
    end_date = Date.today - 1  # archive doesn't include today
    start_date = end_date - 10

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

  def extract_temp_from_history(history, current)
    temps = history.dig("daily", "temperature_2m_mean") || []
    temps = temps.compact

    current_temp = current[:temp]
    temps << current_temp if current_temp

    if temps.any?
      { avg: temps.sum / temps.size.to_f }
    else
      { avg: current_temp || 10.0 }
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
