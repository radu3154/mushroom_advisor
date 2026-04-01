class ScoringEngine
  # Scores a species against current weather data.
  # Returns a hash with :score, :label, :best_time, :explanation, :habitat
  #
  # weather_data shape:
  #   { avg_temp:, total_rain_7d:, days_since_rain:, current_month: }

  LABELS = {
    (80..100) => { label: "EXCELLENT", message: "Perfect conditions — get your basket!" },
    (60..79)  => { label: "GOOD",      message: "Solid conditions — worth a trip." },
    (40..59)  => { label: "FAIR",      message: "Might find some — manage expectations." },
    (20..39)  => { label: "POOR",      message: "Unlikely — consider waiting." },
    (0..19)   => { label: "SKIP",      message: "Not the right time. Stay cozy indoors." }
  }.freeze

  OUT_OF_SEASON = {
    score: 0,
    breakdown: { season: 0, temperature: 0, rain: 0, timing: 0 },
    label: "OUT OF SEASON",
    message: "This species doesn't fruit this time of year. Check back when season opens.",
    out_of_season: true
  }.freeze

  def initialize(species_key, weather_data)
    @species = Species.find(species_key)
    @weather = weather_data
    raise ArgumentError, "Unknown species: #{species_key}" unless @species
  end

  def call
    # Hard stop: if it's not the season, score is 0 — no point checking anything else
    unless in_season_or_adjacent?
      return OUT_OF_SEASON.merge(
        best_time: season_window_text,
        explanation: "Out of season. #{@species[:name]} fruits #{month_names(@species[:season_months])}.",
        habitat: @species[:habitat],
        tips: @species[:tips]
      )
    end

    scores = {
      season: score_season,
      temperature: score_temperature,
      rain: score_rain,
      timing: score_timing
    }

    total = scores.values.sum
    label_info = label_for(total)

    {
      score: total,
      breakdown: scores,
      label: label_info[:label],
      message: label_info[:message],
      best_time: compute_best_time,
      explanation: build_explanation(scores, @weather),
      habitat: @species[:habitat],
      tips: @species[:tips]
    }
  end

  private

  # --- Season (0–20) ---
  def score_season
    if @species[:season_months].include?(@weather[:current_month])
      20
    elsif adjacent_month?
      8
    else
      0
    end
  end

  def adjacent_month?
    @species[:season_months].any? do |m|
      (m - @weather[:current_month]).abs <= 1 ||
        (m - @weather[:current_month]).abs == 11 # wrap Dec ↔ Jan
    end
  end

  # --- Temperature (0–30) ---
  def score_temperature
    range = @species[:temp_range]
    temp = @weather[:avg_temp]

    if temp.between?(range[:ideal_min], range[:ideal_max])
      30
    elsif temp.between?(range[:abs_min], range[:abs_max])
      # linear falloff outside ideal but inside absolute
      if temp < range[:ideal_min]
        proportion = (temp - range[:abs_min]).to_f / (range[:ideal_min] - range[:abs_min])
      else
        proportion = (range[:abs_max] - temp).to_f / (range[:abs_max] - range[:ideal_max])
      end
      (proportion * 20).round.clamp(0, 20)
    else
      0
    end
  end

  # --- Rain last 7 days (0–30) ---
  def score_rain
    range = @species[:rain_range]
    rain = @weather[:total_rain_7d]

    if rain.between?(range[:ideal_min], range[:ideal_max])
      30
    elsif rain.between?(range[:abs_min], range[:abs_max])
      if rain < range[:ideal_min]
        proportion = (rain - range[:abs_min]).to_f / (range[:ideal_min] - range[:abs_min])
      else
        proportion = (range[:abs_max] - rain).to_f / (range[:abs_max] - range[:ideal_max])
      end
      (proportion * 20).round.clamp(0, 20)
    else
      0
    end
  end

  # --- Timing after rain (0–20) ---
  def score_timing
    range = @species[:delay_days]
    days = @weather[:days_since_rain]

    if days.between?(range[:ideal_min], range[:ideal_max])
      20
    elsif days.between?(range[:abs_min], range[:abs_max])
      if days < range[:ideal_min]
        proportion = (days - range[:abs_min]).to_f / (range[:ideal_min] - range[:abs_min])
      else
        proportion = (range[:abs_max] - days).to_f / (range[:abs_max] - range[:ideal_max])
      end
      (proportion * 12).round.clamp(0, 12)
    else
      0
    end
  end

  # --- Helpers ---

  def in_season_or_adjacent?
    @species[:season_months].include?(@weather[:current_month]) || adjacent_month?
  end

  def season_window_text
    months = @species[:season_months]
    first = Date::MONTHNAMES[months.first]
    last = Date::MONTHNAMES[months.last]
    "Wait for #{first}–#{last}"
  end

  def month_names(months)
    months.map { |m| Date::MONTHNAMES[m] }.join(", ")
  end

  def label_for(score)
    LABELS.find { |range, _| range.include?(score) }&.last ||
      { label: "UNKNOWN", message: "Something went wrong." }
  end

  def compute_best_time
    ideal_min = @species[:delay_days][:ideal_min]
    ideal_max = @species[:delay_days][:ideal_max]
    days_since = @weather[:days_since_rain]

    if days_since < ideal_min
      wait = ideal_min - days_since
      "in #{wait}–#{wait + (ideal_max - ideal_min)} days"
    elsif days_since.between?(ideal_min, ideal_max)
      "right now — you're in the sweet spot!"
    else
      "wait for the next good rain, then #{ideal_min}–#{ideal_max} days after"
    end
  end

  def build_explanation(scores, weather)
    rain_mm = weather[:total_rain_7d] || 0
    temp = weather[:avg_temp] || 0
    days = weather[:days_since_rain] || 0
    rain_range = @species[:rain_range]
    temp_range = @species[:temp_range]

    parts = []

    parts << if scores[:season] == 20
      "peak season"
    elsif scores[:season] > 0
      "near season edge"
    else
      "out of season"
    end

    parts << if scores[:temperature] >= 25
      "ideal temperature (#{temp}°C)"
    elsif scores[:temperature] >= 15
      "acceptable temperature (#{temp}°C)"
    elsif temp < temp_range[:abs_min]
      "too cold (#{temp}°C, needs #{temp_range[:ideal_min]}–#{temp_range[:ideal_max]}°C)"
    else
      "too warm (#{temp}°C, needs #{temp_range[:ideal_min]}–#{temp_range[:ideal_max]}°C)"
    end

    parts << if scores[:rain] >= 25
      "great rainfall (#{rain_mm}mm)"
    elsif scores[:rain] >= 15
      "decent rainfall (#{rain_mm}mm)"
    elsif rain_mm < rain_range[:abs_min]
      "too dry (#{rain_mm}mm, needs #{rain_range[:ideal_min]}–#{rain_range[:ideal_max]}mm)"
    else
      "too wet (#{rain_mm}mm, ideal is #{rain_range[:ideal_min]}–#{rain_range[:ideal_max]}mm)"
    end

    ideal_min_delay = @species[:delay_days][:ideal_min]
    ideal_max_delay = @species[:delay_days][:ideal_max]
    wait_min = ideal_min_delay - days
    wait_max = ideal_max_delay - days

    parts << if scores[:timing] >= 15
      "perfect timing after rain"
    elsif scores[:timing] >= 8
      "okay timing (#{days} days since rain)"
    elsif days < ideal_min_delay
      "too soon after rain (#{days} days ago)"
    else
      "too long since rain (#{days} days ago)"
    end

    parts.join(" · ").capitalize
  end
end
