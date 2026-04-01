class MushroomsController < ApplicationController
  before_action :set_lang

  def index
    @species = Species.all
    @location_tree_json = Location.to_json_tree
  end

  def score
    species_key = params[:species]
    location = Location.find(params[:country], params[:city], params[:region])

    unless Species.find(species_key)
      return render json: { error: "Unknown species" }, status: :unprocessable_entity
    end

    unless location
      flash[:error] = "Please select a valid location."
      return redirect_to root_path
    end

    weather_data = if demo_mode?
      WeatherService.demo_data(month: Time.now.month)
    else
      WeatherService.new.fetch_for_location(lat: location[:lat], lon: location[:lon])
    end

    result = ScoringEngine.new(species_key, weather_data).call
    species_info = Species.find(species_key)

    @result = result.merge(
      species_name: Species.localized(species_info, :name, @lang),
      species_latin: species_info[:latin],
      weather: weather_data[:raw] || {},
      location_name: location[:name],
      habitat: Species.localized(species_info, :habitat, @lang),
      tips: Species.localized(species_info, :tips, @lang),
      weather_stats: {
        avg_temp: weather_data[:avg_temp],
        total_rain: weather_data[:total_rain_7d],
        days_since_rain: weather_data[:days_since_rain]
      }
    )

    respond_to do |format|
      format.html { render :score }
      format.json { render json: @result }
    end
  rescue WeatherService::WeatherError => e
    Rails.logger.error "WeatherService error: #{e.message}"
    flash.now[:error] = "Weather data unavailable: #{e.message}. Showing demo results."
    weather_data = WeatherService.demo_data(month: Time.now.month)
    result = ScoringEngine.new(species_key, weather_data).call
    species_info = Species.find(species_key)

    @result = result.merge(
      species_name: Species.localized(species_info, :name, @lang),
      species_latin: species_info[:latin],
      weather: weather_data[:raw],
      location_name: location&.dig(:name) || "Demo Forest",
      habitat: Species.localized(species_info, :habitat, @lang),
      tips: Species.localized(species_info, :tips, @lang),
      demo: true
    )
    render :score
  end

  private

  def set_lang
    @lang = %w[en ro].include?(params[:lang]) ? params[:lang] : "en"
  end

  def demo_mode?
    OPEN_WEATHER_API_KEY == "YOUR_API_KEY_HERE" || params[:demo] == "true"
  end
end
