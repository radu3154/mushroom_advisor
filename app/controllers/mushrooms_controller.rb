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

    weather_data = WeatherService.new.fetch_for_location(lat: location[:lat], lon: location[:lon])

    result = ScoringEngine.new(species_key, weather_data, lang: @lang).call
    species_info = Species.find(species_key)

    @result = result.merge(
      species_name: Species.localized(species_info, :name, @lang),
      species_latin: species_info[:latin],
      weather: weather_data[:raw] || {},
      location_name: location[:name],
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
    flash[:error] = I18nHelper.t(:weather_error, @lang) || "Weather data is temporarily unavailable. Please try again later."
    redirect_to root_path(lang: @lang)
  end

  private

  def set_lang
    @lang = %w[en ro].include?(params[:lang]) ? params[:lang] : "en"
  end

end
