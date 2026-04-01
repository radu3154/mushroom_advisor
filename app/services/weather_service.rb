require "net/http"
require "json"
require "uri"

class WeatherService
  OPENWEATHER_URL = "https://api.openweathermap.org/data/2.5".freeze
  OPEN_METEO_URL  = "https://archive-api.open-meteo.com/v1/archive".freeze

  class WeatherError < StandardError; end

  def initialize(api_key = OPEN_WEATHER_API_KEY)
    @api_key = api_key
  end

  def fetch_for_location(lat:, lon:)
    # Current conditions from OpenWeather
    current = fetch_json("#{OPENWEATHER_URL}/weather?lat=#{lat}&lon=#{lon}&units=metric&appid=#{@api_key}")

    # Historical rain from Open-Meteo (last 10 days, free, no key needed)
    history = fetch_open_meteo_history(lat, lon)

    temp_data = extract_temp_from_history(history, current)
    rain_data = extract_rain_from_history(history)

    {
      avg_temp: temp_data[:avg].round(1),
      total_rain_7d: rain_data[:total_7d].round(1),
      days_since_rain: rain_data[:days_since],
      current_month: Time.now.month,
      raw: {
        current_temp: current.dig("main", "temp"),
        description: current.dig("weather", 0, "description"),
        humidity: current.dig("main", "humidity"),
        location_name: current["name"],
        rain_detail: rain_data[:detail],
        rain_daily: rain_data[:daily]
      }
    }
  rescue => e
    raise WeatherError, "Failed to fetch weather: #{e.message}"
  end

  def self.demo_data(month: Time.now.month)
    {
      avg_temp: 13.5,
      total_rain_7d: 18.0,
      days_since_rain: 3,
      current_month: month,
      raw: {
        current_temp: 14.2,
        description: "partly cloudy",
        humidity: 72,
        location_name: "Demo Forest",
        rain_detail: "demo data",
        rain_daily: []
      }
    }
  end

  private

  def fetch_json(url)
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 10
    http.read_timeout = 10

    request = Net::HTTP::Get.new(uri.request_uri)
    Rails.logger.info "Fetching JSON from #{url}"
    response = http.request(request)
    Rails.logger.info "Response: #{response.body}"

    unless response.is_a?(Net::HTTPSuccess)
      raise WeatherError, "API returned #{response.code}: #{response.body}"
    end

    JSON.parse(response.body)
  end

  # Fetches last 10 days of daily rain and temperature from Open-Meteo
  def fetch_open_meteo_history(lat, lon)
    end_date = Date.today
    start_date = end_date - 10

    url = "#{OPEN_METEO_URL}?latitude=#{lat}&longitude=#{lon}" \
          "&start_date=#{start_date}&end_date=#{end_date}" \
          "&daily=rain_sum,temperature_2m_mean" \
          "&timezone=auto"

    fetch_json(url)
  end

  def extract_rain_from_history(history)
    dates = history.dig("daily", "time") || []
    rains = history.dig("daily", "rain_sum") || []

    # Build daily rain array
    daily = dates.zip(rains).map { |d, r| { date: d, rain_mm: r || 0 } }

    # Last 7 days total
    last_7 = daily.last(7)
    total_7d = last_7.sum { |d| d[:rain_mm] }

    # Days since last significant rain (> 1mm)
    days_since = 0
    daily.reverse.each do |d|
      break if d[:rain_mm] >= 1.0
      days_since += 1
    end

    detail = last_7.map { |d| "#{d[:date]}: #{d[:rain_mm]}mm" }.join(", ")

    {
      total_7d: total_7d,
      days_since: [days_since, 0].max,
      detail: "Last 7 days total: #{total_7d.round(1)}mm. #{detail}",
      daily: daily
    }
  end

  def extract_temp_from_history(history, current)
    temps = history.dig("daily", "temperature_2m_mean") || []
    temps = temps.compact

    # Add current temp for freshness
    current_temp = current.dig("main", "temp")
    temps << current_temp if current_temp

    if temps.any?
      { avg: temps.sum / temps.size.to_f, min: temps.min, max: temps.max }
    else
      { avg: current_temp || 10.0, min: current_temp || 5.0, max: current_temp || 15.0 }
    end
  end
end
