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

    # Weather only — terrain is fetched lazily via check_terrain AJAX.
    weather_data = WeatherService.new.fetch_for_location(lat: lat, lon: lon, temp_window: temp_window)

    result = ScoringEngine.new(species_key, weather_data, lang: @lang).call

    @result = result.merge(
      species_key: species_key,
      species_name: Species.localized(species_info, :name, @lang),
      species_latin: species_info[:latin],
      weather: weather_data[:raw] || {},
      location_name: location_name,
      lat: lat,
      lon: lon,
      elevation: weather_data[:elevation],
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

  # AJAX endpoint — terrain detection on demand.
  # Called when user clicks "Check terrain" button.
  def check_terrain
    lat = params[:lat].to_f
    lon = params[:lon].to_f
    elevation = params[:elevation].presence&.to_f
    species_key = params[:species]
    lang = %w[en ro].include?(params[:lang]) ? params[:lang] : "ro"

    land_cover = LandCoverService.detect(lat: lat, lon: lon, elevation: elevation)

    # Refine with elevation if needed (forest type, alpine meadow)
    if land_cover[:type] == "unknown" || land_cover.delete(:needs_elevation)
      land_cover = LandCoverService.refine_with_elevation(land_cover, elevation)
    end

    terrain_label = lang == "ro" ? land_cover[:label_ro] : land_cover[:label_en]
    terrain_match = ScoringEngine.terrain_match(species_key, land_cover[:type])
    is_water = land_cover[:type] == "water"
    is_urban = ScoringEngine::URBAN_TYPES.include?(land_cover[:type])

    match_key = :"terrain_#{terrain_match}"
    match_text = I18nHelper.t(match_key, lang)

    render json: {
      terrain_label: terrain_label,
      terrain_match: terrain_match,
      match_text: match_text,
      is_water: is_water,
      is_urban: is_urban,
      water_message: is_water ? (lang == "ro" ? "Pinul e pe apă. Mută-l pe uscat pentru rezultate." : "Pin is on water. Move it to dry land for results.") : nil,
      urban_message: is_urban ? (lang == "ro" ? "Zonă urbană — mută pinul spre o pădure sau pajiște." : "Urban area — try moving the pin to a forest or meadow.") : nil
    }
  rescue => e
    Rails.logger.error "CheckTerrain error: #{e.message}"
    render json: { error: true, terrain_label: lang == "ro" ? "Eroare detecție teren" : "Terrain detection error" }, status: :ok
  end

  private

  def set_lang
    @lang = %w[en ro].include?(params[:lang]) ? params[:lang] : "ro"
  end

end
