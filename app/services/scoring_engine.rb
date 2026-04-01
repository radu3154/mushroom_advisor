class ScoringEngine
  # Scores a species against current weather data.
  # Returns a hash with :score, :label, :best_time, :explanation, :habitat
  #
  # weather_data shape:
  #   { avg_temp:, total_rain_7d:, days_since_rain:, current_month: }

  # tier is always English (for CSS), label/message are localized
  LABELS = {
    "en" => {
      (80..100) => { tier: "excellent", label: "EXCELLENT", message: "Perfect conditions — get your basket!" },
      (60..79)  => { tier: "good",      label: "GOOD",      message: "Solid conditions — worth a trip." },
      (40..59)  => { tier: "fair",      label: "FAIR",      message: "Might find some — manage expectations." },
      (20..39)  => { tier: "poor",      label: "POOR",      message: "Unlikely — consider waiting." },
      (0..19)   => { tier: "skip",      label: "SKIP",      message: "Not the right time. Stay cozy indoors." }
    },
    "ro" => {
      (80..100) => { tier: "excellent", label: "EXCELENT",    message: "Condiții perfecte — ia coșul!" },
      (60..79)  => { tier: "good",      label: "BINE",        message: "Condiții bune — merită o ieșire." },
      (40..59)  => { tier: "fair",      label: "ACCEPTABIL",  message: "S-ar putea să găsești ceva — fără așteptări mari." },
      (20..39)  => { tier: "poor",      label: "SLAB",        message: "Puțin probabil — mai bine aștepți." },
      (0..19)   => { tier: "skip",      label: "EVITĂ",       message: "Nu e momentul potrivit. Stai la căldură." }
    }
  }.freeze

  OUT_OF_SEASON_LABELS = {
    "en" => { tier: "out-of-season", label: "OUT OF SEASON", message: "This species doesn't fruit this time of year. Check back when season opens." },
    "ro" => { tier: "out-of-season", label: "ÎN AFARA SEZONULUI", message: "Această specie nu fructifică în această perioadă. Revino când se deschide sezonul." }
  }.freeze

  MONTH_NAMES_RO = [nil, "Ianuarie", "Februarie", "Martie", "Aprilie", "Mai", "Iunie",
                    "Iulie", "August", "Septembrie", "Octombrie", "Noiembrie", "Decembrie"].freeze

  def initialize(species_key, weather_data, lang: "en")
    @species = Species.find(species_key)
    @weather = weather_data
    @lang = lang
    raise ArgumentError, "Unknown species: #{species_key}" unless @species
  end

  def call
    unless in_season_or_adjacent?
      oos = OUT_OF_SEASON_LABELS[@lang] || OUT_OF_SEASON_LABELS["en"]
      species_name = Species.localized(@species, :name, @lang)
      return {
        score: 0,
        breakdown: { season: 0, temperature: 0, rain: 0, timing: 0 },
        tier: oos[:tier],
        label: oos[:label],
        message: oos[:message],
        out_of_season: true,
        best_time: season_window_text,
        explanation: out_of_season_explanation(species_name),
        habitat: Species.localized(@species, :habitat, @lang),
        tips: Species.localized(@species, :tips, @lang)
      }
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
      tier: label_info[:tier],
      label: label_info[:label],
      message: label_info[:message],
      best_time: compute_best_time,
      explanation: build_explanation(scores, @weather),
      habitat: Species.localized(@species, :habitat, @lang),
      tips: Species.localized(@species, :tips, @lang)
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
        (m - @weather[:current_month]).abs == 11
    end
  end

  # --- Temperature (0–30) ---
  def score_temperature
    range = @species[:temp_range]
    temp = @weather[:avg_temp]

    if temp.between?(range[:ideal_min], range[:ideal_max])
      30
    elsif temp.between?(range[:abs_min], range[:abs_max])
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

  def month_name(m)
    @lang == "ro" ? MONTH_NAMES_RO[m] : Date::MONTHNAMES[m]
  end

  def season_window_text
    months = @species[:season_months]
    first = month_name(months.first)
    last = month_name(months.last)
    @lang == "ro" ? "Așteaptă #{first}–#{last}" : "Wait for #{first}–#{last}"
  end

  def out_of_season_explanation(species_name)
    month_list = @species[:season_months].map { |m| month_name(m) }.join(", ")
    if @lang == "ro"
      "În afara sezonului. #{species_name} fructifică în #{month_list}."
    else
      "Out of season. #{species_name} fruits #{month_list}."
    end
  end

  def label_for(score)
    labels = LABELS[@lang] || LABELS["en"]
    labels.find { |range, _| range.include?(score) }&.last ||
      { label: "UNKNOWN", message: "Something went wrong." }
  end

  def compute_best_time
    ideal_min = @species[:delay_days][:ideal_min]
    ideal_max = @species[:delay_days][:ideal_max]
    days_since = @weather[:days_since_rain]

    if days_since < ideal_min
      wait = ideal_min - days_since
      if @lang == "ro"
        "în #{wait}–#{wait + (ideal_max - ideal_min)} zile"
      else
        "in #{wait}–#{wait + (ideal_max - ideal_min)} days"
      end
    elsif days_since.between?(ideal_min, ideal_max)
      @lang == "ro" ? "chiar acum — ești în momentul ideal!" : "right now — you're in the sweet spot!"
    else
      if @lang == "ro"
        "așteaptă următoarea ploaie bună, apoi #{ideal_min}–#{ideal_max} zile după"
      else
        "wait for the next good rain, then #{ideal_min}–#{ideal_max} days after"
      end
    end
  end

  def build_explanation(scores, weather)
    rain_mm = weather[:total_rain_7d] || 0
    temp = weather[:avg_temp] || 0
    days = weather[:days_since_rain] || 0
    rain_range = @species[:rain_range]
    temp_range = @species[:temp_range]

    parts = []

    if @lang == "ro"
      parts << if scores[:season] == 20
        "sezon de vârf"
      elsif scores[:season] > 0
        "la marginea sezonului"
      else
        "în afara sezonului"
      end

      parts << if scores[:temperature] >= 25
        "temperatură ideală (#{temp}°C)"
      elsif scores[:temperature] >= 15
        "temperatură acceptabilă (#{temp}°C)"
      elsif temp < temp_range[:abs_min]
        "prea frig (#{temp}°C, necesită #{temp_range[:ideal_min]}–#{temp_range[:ideal_max]}°C)"
      else
        "prea cald (#{temp}°C, necesită #{temp_range[:ideal_min]}–#{temp_range[:ideal_max]}°C)"
      end

      parts << if scores[:rain] >= 25
        "precipitații excelente (#{rain_mm}mm)"
      elsif scores[:rain] >= 15
        "precipitații decente (#{rain_mm}mm)"
      elsif rain_mm < rain_range[:abs_min]
        "prea uscat (#{rain_mm}mm, necesită #{rain_range[:ideal_min]}–#{rain_range[:ideal_max]}mm)"
      else
        "prea umed (#{rain_mm}mm, ideal #{rain_range[:ideal_min]}–#{rain_range[:ideal_max]}mm)"
      end

      parts << if scores[:timing] >= 15
        "moment perfect după ploaie"
      elsif scores[:timing] >= 8
        "timp acceptabil (#{days} zile de la ploaie)"
      elsif days < @species[:delay_days][:ideal_min]
        "prea devreme după ploaie (#{days} zile)"
      else
        "prea mult de la ultima ploaie (#{days} zile)"
      end
    else
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

      parts << if scores[:timing] >= 15
        "perfect timing after rain"
      elsif scores[:timing] >= 8
        "okay timing (#{days} days since rain)"
      elsif days < ideal_min_delay
        "too soon after rain (#{days} days ago)"
      else
        "too long since rain (#{days} days ago)"
      end
    end

    parts.join(" · ").capitalize
  end
end
