require "date"
require "set"

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
      (0..19)   => { tier: "skip",      label: "EVITĂ",       message: "Nu e momentul potrivit. Stai liniștit acasă." }
    }
  }.freeze

  OUT_OF_SEASON_LABELS = {
    "en" => { tier: "out-of-season", label: "OUT OF SEASON", message: "This species doesn't fruit this time of year. Check back when season opens." },
    "ro" => { tier: "out-of-season", label: "ÎN AFARA SEZONULUI", message: "Această specie nu fructifică în această perioadă. Revino când se deschide sezonul." }
  }.freeze

  WATER_LABELS = {
    "en" => { tier: "skip", label: "SKIP", message: "Mushrooms don't grow underwater. Unless you're looking for fish." },
    "ro" => { tier: "skip", label: "EVITĂ", message: "Ciupercile nu cresc sub apă. Doar dacă pescuiești." }
  }.freeze

  URBAN_LABELS = {
    "en" => { tier: "skip", label: "SKIP", message: "No mushrooms here — try moving the pin to a forest or meadow." },
    "ro" => { tier: "skip", label: "EVITĂ", message: "Aici nu cresc ciuperci — mută pinul spre o pădure sau pajiște." }
  }.freeze

  # Terrain types where mushroom foraging makes no sense.
  URBAN_TYPES = Set.new(%w[
    residential industrial commercial retail construction
    quarry landfill military railway depot garages
    brownfield religious education
  ]).freeze

  MONTH_NAMES_RO = [nil, "Ianuarie", "Februarie", "Martie", "Aprilie", "Mai", "Iunie",
                    "Iulie", "August", "Septembrie", "Octombrie", "Noiembrie", "Decembrie"].freeze

  # With habitat:    Season 25 + Temperature 25 + Rain 25 + Habitat 15 + Timing 10 = 100
  # Without habitat: Season 30 + Temperature 30 + Rain 30 + Timing 10 = 100
  WEIGHTS_WITH_HABITAT    = { season: 25, temperature: 25, rain: 25, habitat: 15, timing: 10 }.freeze
  WEIGHTS_WITHOUT_HABITAT = { season: 30, temperature: 30, rain: 30, timing: 10 }.freeze

  def initialize(species_key, weather_data, lang: "en", land_cover: nil)
    @species = Species.find(species_key)
    @weather = weather_data
    @lang = lang
    @land_cover = land_cover || { type: "unknown" }
    @terrain_known = @land_cover[:type] != "unknown"
    @weights = @terrain_known ? WEIGHTS_WITH_HABITAT : WEIGHTS_WITHOUT_HABITAT
    raise ArgumentError, "Unknown species: #{species_key}" unless @species
  end

  def call
    if @land_cover[:type] == "water"
      wl = WATER_LABELS[@lang] || WATER_LABELS["en"]
      return {
        score: 0,
        breakdown: { season: 0, temperature: 0, rain: 0, habitat: 0, timing: 0 },
        tier: wl[:tier],
        label: wl[:label],
        message: wl[:message],
        on_water: true,
        best_time: nil,
        explanation: @lang == "ro" ? "Ai plasat pinul pe apă. Mută-l pe uscat!" : "You pinned on water. Move the pin to dry land!",
        habitat: Species.localized(@species, :habitat, @lang),
        tips: Species.localized(@species, :tips, @lang)
      }
    end

    if URBAN_TYPES.include?(@land_cover[:type])
      ul = URBAN_LABELS[@lang] || URBAN_LABELS["en"]
      terrain_label = @lang == "ro" ? @land_cover[:label_ro] : @land_cover[:label_en]
      return {
        score: 0,
        breakdown: { season: 0, temperature: 0, rain: 0, habitat: 0, timing: 0 },
        tier: ul[:tier],
        label: ul[:label],
        message: ul[:message],
        on_urban: true,
        best_time: nil,
        explanation: @lang == "ro" ?
          "Ai plasat pinul pe #{terrain_label&.downcase || 'zonă urbană'}. Mută-l spre natură!" :
          "You pinned on #{terrain_label&.downcase || 'urban area'}. Move the pin to nature!",
        habitat: Species.localized(@species, :habitat, @lang),
        tips: Species.localized(@species, :tips, @lang)
      }
    end

    unless in_season?
      oos = OUT_OF_SEASON_LABELS[@lang] || OUT_OF_SEASON_LABELS["en"]
      species_name = Species.localized(@species, :name, @lang)
      breakdown = { season: 0, temperature: 0, rain: 0, timing: 0 }
      breakdown[:habitat] = 0 if @terrain_known
      return {
        score: 0,
        breakdown: breakdown,
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
    scores[:habitat] = score_habitat if @terrain_known

    # If temperature OR rain is completely outside the absolute range, nothing grows.
    # Both are hard biological constraints — no warmth or no moisture = no fruiting.
    total = if (scores[:temperature] == 0 && out_of_abs_range?(:temp)) ||
               (scores[:rain] == 0 && out_of_abs_range?(:rain))
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

  # --- Season ---
  def score_season
    @species[:season_months].include?(@weather[:current_month]) ? @weights[:season] : 0
  end

  # --- Temperature ---
  def score_temperature
    score_range_smooth(@weather[:avg_temp], @species[:temp_range], @weights[:temperature])
  end

  # --- Rain last 7 days ---
  def score_rain
    score_range_smooth(@weather[:total_rain_7d], @species[:rain_range], @weights[:rain])
  end

  # --- Habitat / terrain type (0–15) --- only called when terrain is known
  def score_habitat
    terrain_type = @land_cover[:type]
    prefs = @species[:preferred_terrain] || { ideal: [], partial: [], bad: [] }

    if prefs[:ideal].include?(terrain_type)
      @weights[:habitat]
    elsif prefs[:partial].include?(terrain_type)
      (@weights[:habitat] * 0.5).round
    else
      0
    end
  end

  # --- Timing after rain (0–10) ---
  def score_timing
    score_range_smooth(@weather[:days_since_rain], @species[:delay_days], @weights[:timing])
  end

  # Scoring for a value within a range spec.
  # Ideal range is treated as genuinely good — the whole range scores 80-100%.
  # Mushrooms don't have a single "perfect" temp; the entire ideal range works.
  # Marginal zone: gradient from just below floor near ideal edge → 1 at abs edge.
  # Outside abs → 0.
  IDEAL_FLOOR_RATIO = 0.80

  def score_range_smooth(value, range, max_score)
    floor = (max_score * IDEAL_FLOOR_RATIO).round

    if value.between?(range[:ideal_min], range[:ideal_max])
      # Inside ideal range: gradient from floor at edges to max_score at center
      center = (range[:ideal_min] + range[:ideal_max]) / 2.0
      half_width = (range[:ideal_max] - range[:ideal_min]) / 2.0
      if half_width == 0
        max_score
      else
        distance = (value - center).abs
        ratio = 1.0 - (distance / half_width)
        (floor + ratio * (max_score - floor)).round
      end
    elsif value.between?(range[:abs_min], range[:abs_max])
      # Marginal zone: gradient from (floor - 1) near ideal edge → 1 near abs edge
      if value < range[:ideal_min]
        width = range[:ideal_min] - range[:abs_min]
        ratio = width > 0 ? (value - range[:abs_min]) / width.to_f : 0
      else
        width = range[:abs_max] - range[:ideal_max]
        ratio = width > 0 ? (range[:abs_max] - value) / width.to_f : 0
      end
      marginal_top = [floor - 1, 1].max
      (1 + ratio * (marginal_top - 1)).round
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
    else
      false
    end
  end

  # Only show "best time to go" when timing is the main limiting factor.
  # Hide when temperature or rain are problematic — waiting won't fix those.
  # Both temp and rain must be in ideal range (>= floor) for timing advice to make sense.
  def show_best_time?(total, scores)
    temp_floor = (@weights[:temperature] * IDEAL_FLOOR_RATIO).round
    rain_floor = (@weights[:rain] * IDEAL_FLOOR_RATIO).round
    total > 0 && scores[:temperature] >= temp_floor && scores[:rain] >= rain_floor
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
      { tier: "skip", label: "UNKNOWN", message: "Something went wrong." }
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

    delay = @species[:delay_days]

    if @lang == "ro"
      parts << (scores[:season] >= @weights[:season] ? "sezon de vârf" : "în afara sezonului")
      parts << temp_explanation_ro(temp, temp_range)
      parts << rain_explanation_ro(rain_mm, rain_range)
      parts << habitat_explanation_ro(scores[:habitat]) if scores[:habitat]
      parts << timing_explanation_ro(days, delay)
    else
      parts << (scores[:season] >= @weights[:season] ? "peak season" : "out of season")
      parts << temp_explanation_en(temp, temp_range)
      parts << rain_explanation_en(rain_mm, rain_range)
      parts << habitat_explanation_en(scores[:habitat]) if scores[:habitat]
      parts << timing_explanation_en(days, delay)
    end

    parts.join(" · ").capitalize
  end

  # --- Explanation helpers (value-based, not score-based) ---

  def temp_explanation_ro(temp, r)
    if temp.between?(r[:ideal_min], r[:ideal_max])
      "temperatură bună (#{temp}°C, ideal #{r[:ideal_min]}–#{r[:ideal_max]}°C)"
    elsif temp.between?(r[:abs_min], r[:abs_max])
      temp < r[:ideal_min] ?
        "cam frig (#{temp}°C, ideal #{r[:ideal_min]}–#{r[:ideal_max]}°C)" :
        "cam cald (#{temp}°C, ideal #{r[:ideal_min]}–#{r[:ideal_max]}°C)"
    elsif temp < r[:abs_min]
      "prea frig (#{temp}°C, necesită min #{r[:abs_min]}°C)"
    else
      "prea cald (#{temp}°C, necesită max #{r[:abs_max]}°C)"
    end
  end

  def temp_explanation_en(temp, r)
    if temp.between?(r[:ideal_min], r[:ideal_max])
      "good temperature (#{temp}°C, ideal #{r[:ideal_min]}–#{r[:ideal_max]}°C)"
    elsif temp.between?(r[:abs_min], r[:abs_max])
      temp < r[:ideal_min] ?
        "a bit cold (#{temp}°C, ideal #{r[:ideal_min]}–#{r[:ideal_max]}°C)" :
        "a bit warm (#{temp}°C, ideal #{r[:ideal_min]}–#{r[:ideal_max]}°C)"
    elsif temp < r[:abs_min]
      "too cold (#{temp}°C, needs min #{r[:abs_min]}°C)"
    else
      "too warm (#{temp}°C, needs max #{r[:abs_max]}°C)"
    end
  end

  def rain_explanation_ro(rain_mm, r)
    if rain_mm.between?(r[:ideal_min], r[:ideal_max])
      "precipitații bune (#{rain_mm}mm, ideal #{r[:ideal_min]}–#{r[:ideal_max]}mm)"
    elsif rain_mm.between?(r[:abs_min], r[:abs_max])
      rain_mm < r[:ideal_min] ?
        "cam uscat (#{rain_mm}mm, ideal #{r[:ideal_min]}–#{r[:ideal_max]}mm)" :
        "cam umed (#{rain_mm}mm, ideal #{r[:ideal_min]}–#{r[:ideal_max]}mm)"
    elsif rain_mm < r[:abs_min]
      "prea uscat (#{rain_mm}mm, necesită min #{r[:abs_min]}mm)"
    else
      "prea umed (#{rain_mm}mm, necesită max #{r[:abs_max]}mm)"
    end
  end

  def rain_explanation_en(rain_mm, r)
    if rain_mm.between?(r[:ideal_min], r[:ideal_max])
      "good rainfall (#{rain_mm}mm, ideal #{r[:ideal_min]}–#{r[:ideal_max]}mm)"
    elsif rain_mm.between?(r[:abs_min], r[:abs_max])
      rain_mm < r[:ideal_min] ?
        "a bit dry (#{rain_mm}mm, ideal #{r[:ideal_min]}–#{r[:ideal_max]}mm)" :
        "a bit wet (#{rain_mm}mm, ideal #{r[:ideal_min]}–#{r[:ideal_max]}mm)"
    elsif rain_mm < r[:abs_min]
      "too dry (#{rain_mm}mm, needs min #{r[:abs_min]}mm)"
    else
      "too wet (#{rain_mm}mm, needs max #{r[:abs_max]}mm)"
    end
  end

  def timing_explanation_ro(days, r)
    if days.between?(r[:ideal_min], r[:ideal_max])
      "moment bun după ploaie (#{days} #{zile(days)})"
    elsif days.between?(r[:abs_min], r[:abs_max])
      days < r[:ideal_min] ?
        "cam devreme după ploaie (#{days} #{zile(days)})" :
        "cam mult de la ploaie (#{days} #{zile(days)})"
    elsif days < r[:abs_min]
      "prea devreme după ploaie (#{days} #{zile(days)})"
    else
      "prea mult de la ultima ploaie (#{days} #{zile(days)})"
    end
  end

  def timing_explanation_en(days, r)
    if days.between?(r[:ideal_min], r[:ideal_max])
      "good timing after rain (#{days} #{zile(days)})"
    elsif days.between?(r[:abs_min], r[:abs_max])
      days < r[:ideal_min] ?
        "a bit soon after rain (#{days} #{zile(days)})" :
        "a bit long since rain (#{days} #{zile(days)})"
    elsif days < r[:abs_min]
      "too soon after rain (#{days} #{zile(days)})"
    else
      "too long since rain (#{days} #{zile(days)})"
    end
  end

  def habitat_explanation_ro(habitat_score)
    terrain_label = @land_cover[:label_ro] || "Teren nedetectat"
    if habitat_score >= @weights[:habitat]
      "#{terrain_label} — teren potrivit"
    elsif habitat_score > 0
      "#{terrain_label} — teren acceptabil"
    else
      "#{terrain_label} — teren nepotrivit"
    end
  end

  def habitat_explanation_en(habitat_score)
    terrain_label = @land_cover[:label_en] || "unknown"
    if habitat_score >= @weights[:habitat]
      "#{terrain_label} — good match"
    elsif habitat_score > 0
      "#{terrain_label} — okay match"
    else
      "#{terrain_label} — wrong terrain"
    end
  end
end
