class MushroomsController < ApplicationController
  before_action :set_lang

  def index
    @species = Species.all
  end

  def score
    species_key = params[:species]
    lat = params[:lat].to_f
    lon = params[:lon].to_f
    location_name = params[:location_name].presence || "#{lat.round(2)}, #{lon.round(2)}"

    unless Species.find(species_key)
      return render json: { error: "Unknown species" }, status: :unprocessable_entity
    end

    if lat == 0.0 && lon == 0.0
      flash[:error] = I18nHelper.t(:hint_location, @lang)
      return redirect_to root_path(lang: @lang)
    end

    weather_data = WeatherService.new.fetch_for_location(lat: lat, lon: lon)

    # Detect land cover (terrain type) at this location.
    # Cache via params so language-switching doesn't re-query the Overpass API.
    if params[:terrain_type].present? && params[:terrain_label_en].present?
      land_cover = {
        type: params[:terrain_type],
        label_en: params[:terrain_label_en],
        label_ro: params[:terrain_label_ro] || params[:terrain_label_en],
        source: "cached"
      }
    else
      land_cover = LandCoverService.detect(lat: lat, lon: lon, elevation: weather_data[:elevation])
    end

    result = ScoringEngine.new(species_key, weather_data, lang: @lang, land_cover: land_cover).call
    species_info = Species.find(species_key)

    # Inject terrain into params so the lang-switch form carries it forward
    params[:terrain_type] = land_cover[:type]
    params[:terrain_label_en] = land_cover[:label_en]
    params[:terrain_label_ro] = land_cover[:label_ro]

    terrain_label = @lang == "ro" ? land_cover[:label_ro] : land_cover[:label_en]

    @result = result.merge(
      species_name: Species.localized(species_info, :name, @lang),
      species_latin: species_info[:latin],
      weather: weather_data[:raw] || {},
      location_name: location_name,
      land_cover: land_cover,
      terrain_label: terrain_label,
      weather_stats: {
        avg_temp: weather_data[:avg_temp],
        total_rain: weather_data[:total_rain_7d],
        days_since_rain: weather_data[:days_since_rain],
        elevation: weather_data[:elevation]
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
    @lang = %w[en ro].include?(params[:lang]) ? params[:lang] : "ro"
  end

end
