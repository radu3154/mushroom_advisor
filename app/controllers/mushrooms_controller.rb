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

    species_info = Species.find(species_key)
    unless species_info
      return render json: { error: "Unknown species" }, status: :unprocessable_entity
    end

    if lat == 0.0 && lon == 0.0
      flash[:error] = I18nHelper.t(:hint_location, @lang)
      return redirect_to root_path(lang: @lang)
    end

    # Species-specific temp averaging window (soil-temp proxy for morels, etc.)
    temp_window = species_info[:temp_window] || 7

    # Fetch weather and terrain IN PARALLEL when terrain isn't cached.
    terrain_cached = params[:terrain_type].present? && params[:terrain_label_en].present?

    if terrain_cached
      land_cover = {
        type: params[:terrain_type],
        label_en: params[:terrain_label_en],
        label_ro: params[:terrain_label_ro] || params[:terrain_label_en],
        source: "cached"
      }
      weather_data = WeatherService.new.fetch_for_location(lat: lat, lon: lon, temp_window: temp_window)
    else
      weather_data = nil
      land_cover = nil
      weather_thread = Thread.new { weather_data = WeatherService.new.fetch_for_location(lat: lat, lon: lon, temp_window: temp_window) }
      terrain_thread = Thread.new { land_cover = LandCoverService.detect(lat: lat, lon: lon) }
      weather_thread.join
      terrain_thread.join

      # Refine terrain with elevation from weather (alpine meadow, forest type)
      if land_cover[:type] == "unknown" || land_cover.delete(:needs_elevation)
        land_cover = LandCoverService.refine_with_elevation(land_cover, weather_data[:elevation])
      end
    end

    result = ScoringEngine.new(species_key, weather_data, lang: @lang, land_cover: land_cover).call

    # Inject terrain into params so the lang-switch form carries it forward
    params[:terrain_type] = land_cover[:type]
    params[:terrain_label_en] = land_cover[:label_en]
    params[:terrain_label_ro] = land_cover[:label_ro]

    terrain_label = @lang == "ro" ? land_cover[:label_ro] : land_cover[:label_en]
    terrain_match = ScoringEngine.terrain_match(species_key, land_cover[:type])

    @result = result.merge(
      species_name: Species.localized(species_info, :name, @lang),
      species_latin: species_info[:latin],
      weather: weather_data[:raw] || {},
      location_name: location_name,
      land_cover: land_cover,
      terrain_label: terrain_label,
      terrain_match: terrain_match,
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
