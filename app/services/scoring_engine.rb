require "date"

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
    unless in_season?
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

    # If temperature or rain is completely outside the absolute range, nothing grows
    total = if scores[:temperature] == 0 && out_of_abs_range?(:temp)
              0
            elsif scores[:rain] == 0 && out_of_abs_range?(:rain)
              0
            else
              scores.values.sum
            end

    label_info = label_for(total)

    {
      score: total,
      breakdown: scores,
      tier: label_info[:tier],
      label: label_info[:label],
      message: label_info[:message],
      best_time: show_best_time?(total, scores) ? compute_best_time : nil,
      explanation: build_explanation(scores, @weather),
      habitat: Species.localized(@species, :habitat, @lang),
      tips: Species.localized(@species, :tips, @lang)
    }
  end

  private

  # --- Season (0–25) ---
  # In season = 25, out of season = 0 (no "adjacent" fudging)
  def score_season
    @species[:season_months].include?(@weather[:current_month]) ? 25 : 0
  end

  # --- Temperature (0–25) ---
  # Smooth gradient: 0 at abs boundary → 25 at ideal boundary (no cliff)
  def score_temperature
    score_range_smooth(@weather[:avg_temp], @species[:temp_range], 25)
  end

  # --- Rain last 7 days (0–25) ---
  def score_rain
    score_range_smooth(@weather[:total_rain_7d], @species[:rain_range], 25)
  end

  # --- Timing after rain (0–25) ---
  def score_timing
    score_range_smooth(@weather[:days_since_rain], @species[:delay_days], 25)
  end

  # Scoring for a value within a range spec.
  # Inside ideal → max_score (25). Between abs and ideal → 5 (marginal).
  # Outside abs → 0 (impossible conditions).
  def score_range_smooth(value, range, max_score)
    if value.between?(range[:ideal_min], range[:ideal_max])
      max_score
    elsif value.between?(range[:abs_min], range[:abs_max])
      5
    else
      0
    end
  end

  # --- Helpers ---

  def in_season?
    @species[:season_months].include?(@weather[:current_month])
  end

  def month_name(m)
    @lang == "ro" ? MONTH_NAMES_RO[m] : Date::MONTHNAMES[m]
  end

  def out_of_abs_range?(type)
    case type
    when :temp
      temp = @weather[:avg_temp]
      temp < @species[:temp_range][:abs_min] || temp > @species[:temp_range][:abs_max]
    when :rain
      rain = @weather[:total_rain_7d]
      rain < @species[:rain_range][:abs_min] || rain > @species[:rain_range][:abs_max]
    end
  end

  # Only show "best time to go" when it's actually useful:
  # - Score > 0 (not hard-zeroed by extreme conditions)
  # - Temperature and rain are at least marginal (> 0), otherwise
  #   waiting more days won't help — the weather itself is wrong
  def show_best_time?(total, scores)
    total > 0 && scores[:temperature] > 0 && scores[:rain] > 0
  end

  def zile(n)
    @lang == "ro" ? (n == 1 ? "zi" : "zile") : (n == 1 ? "day" : "days")
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
      wait_min = ideal_min - days_since
      wait_max = wait_min + (ideal_max - ideal_min)
      if @lang == "ro"
        "în #{wait_min}–#{wait_max} #{zile(wait_max)}"
      else
        "in #{wait_min}–#{wait_max} #{zile(wait_max)}"
      end
    elsif days_since.between?(ideal_min, ideal_max)
      @lang == "ro" ? "chiar acum — ești în momentul ideal!" : "right now — you're in the sweet spot!"
    else
      if @lang == "ro"
        "așteaptă următoarea ploaie bună, apoi #{ideal_min}–#{ideal_max} #{zile(ideal_max)} după"
      else
        "wait for the next good rain, then #{ideal_min}–#{ideal_max} #{zile(ideal_max)} after"
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
      parts << (scores[:season] == 25 ? "sezon de vârf" : "în afara sezonului")

      parts << if scores[:temperature] >= 20
        "temperatură ideală (#{temp}°C)"
      elsif scores[:temperature] >= 12
        "temperatură acceptabilă (#{temp}°C)"
      elsif temp < temp_range[:ideal_min]
        "prea frig (#{temp}°C, necesită #{temp_range[:ideal_min]}–#{temp_range[:ideal_max]}°C)"
      else
        "prea cald (#{temp}°C, necesită #{temp_range[:ideal_min]}–#{temp_range[:ideal_max]}°C)"
      end

      parts << if scores[:rain] >= 20
        "precipitații excelente (#{rain_mm}mm)"
      elsif scores[:rain] >= 12
        "precipitații decente (#{rain_mm}mm)"
      elsif rain_mm < rain_range[:ideal_min]
        "prea uscat (#{rain_mm}mm, necesită #{rain_range[:ideal_min]}–#{rain_range[:ideal_max]}mm)"
      else
        "prea umed (#{rain_mm}mm, ideal #{rain_range[:ideal_min]}–#{rain_range[:ideal_max]}mm)"
      end

      parts << if scores[:timing] >= 20
        "moment perfect după ploaie"
      elsif scores[:timing] >= 12
        "timp acceptabil (#{days} #{zile(days)} de la ploaie)"
      elsif days < @species[:delay_days][:ideal_min]
        "prea devreme după ploaie (#{days} #{zile(days)})"
      else
        "prea mult de la ultima ploaie (#{days} #{zile(days)})"
      end
    else
      parts << (scores[:season] == 25 ? "peak season" : "out of season")

      parts << if scores[:temperature] >= 20
        "ideal temperature (#{temp}°C)"
      elsif scores[:temperature] >= 12
        "acceptable temperature (#{temp}°C)"
      elsif temp < temp_range[:ideal_min]
        "too cold (#{temp}°C, needs #{temp_range[:ideal_min]}–#{temp_range[:ideal_max]}°C)"
      else
        "too warm (#{temp}°C, needs #{temp_range[:ideal_min]}–#{temp_range[:ideal_max]}°C)"
      end

      parts << if scores[:rain] >= 20
        "great rainfall (#{rain_mm}mm)"
      elsif scores[:rain] >= 12
        "decent rainfall (#{rain_mm}mm)"
      elsif rain_mm < rain_range[:ideal_min]
        "too dry (#{rain_mm}mm, needs #{rain_range[:ideal_min]}–#{rain_range[:ideal_max]}mm)"
      else
        "too wet (#{rain_mm}mm, ideal is #{rain_range[:ideal_min]}–#{rain_range[:ideal_max]}mm)"
      end

      parts << if scores[:timing] >= 20
        "perfect timing after rain"
      elsif scores[:timing] >= 12
        "okay timing (#{days} #{zile(days)} since rain)"
      elsif days < @species[:delay_days][:ideal_min]
        "too soon after rain (#{days} #{zile(days)} ago)"
      else
        "too long since rain (#{days} #{zile(days)} ago)"
      end
    end

    parts.join(" · ").capitalize
  end
end
