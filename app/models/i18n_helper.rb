class I18nHelper
  TRANSLATIONS = {
    "en" => {
      header_title: "Mushroom Advisor",
      header_subtitle: "Should you go foraging today? Let the weather decide.",
      pick_mushroom: "Pick your mushroom",
      choose_location: "Choose your location",
      check_conditions: "Check Conditions",
      hint_both: "Select a mushroom and a location on the map",
      hint_mushroom: "Now pick a mushroom above",
      hint_location: "Now tap a location on the map",
      hint_ready: "Ready! Checking %{species} conditions near %{location}",
      use_my_location: "Use my location",
      locating: "Locating...",
      location_error: "Could not get your location. Please tap the map instead.",
      tap_map_hint: "Tap the map or use GPS to pick a foraging spot",
      back_link: "Pick a different mushroom",
      best_time: "Best time to go:",
      what_data_says: "What the data says",
      foraging_tips: "Foraging tips",
      currently: "Currently:",
      humidity: "humidity",
      rainfall_chart: "Rainfall last 7 days (mm)",
      weather_error: "Weather data is temporarily unavailable. Please try again later.",
      footer: "Made with care for foragers everywhere. Not a field guide \u2014 always verify with an expert.",
      season: "Season",
      temperature: "Temperature",
      rain: "Rain",
      timing: "Timing",
      check_terrain: "Check terrain",
      terrain_ideal: "Great terrain for this species!",
      terrain_partial: "Acceptable terrain — not ideal, but possible.",
      terrain_bad: "Wrong terrain for this species.",
      terrain_unknown: "Terrain compatibility unknown.",
      days_since_rain: "days since rain"
    },
    "ro" => {
      header_title: "Sfatul Ciupercarului",
      header_subtitle: "Mergi la ciuperci azi? Las\u0103 vremea s\u0103 decid\u0103.",
      pick_mushroom: "Alege ciuperca",
      choose_location: "Alege loca\u021Bia",
      check_conditions: "Verific\u0103 Condi\u021Biile",
      hint_both: "Alege o ciuperc\u0103 \u0219i o loca\u021Bie pe hart\u0103",
      hint_mushroom: "Acum alege o ciuperc\u0103 de mai sus",
      hint_location: "Acum atinge harta pentru a alege locul",
      hint_ready: "Gata! Verific condi\u021Biile pentru %{species} l\u00E2ng\u0103 %{location}",
      use_my_location: "Locația mea",
      locating: "Se caută...",
      location_error: "Nu s-a putut determina locația. Atinge harta manual.",
      tap_map_hint: "Atinge harta sau folosește GPS-ul pentru a alege locul de cules",
      back_link: "Alege alt\u0103 ciuperc\u0103",
      best_time: "Cel mai bun moment:",
      what_data_says: "Ce spun datele",
      foraging_tips: "Sfaturi de cules",
      currently: "\u00CEn prezent:",
      humidity: "umiditate",
      rainfall_chart: "Precipita\u021Bii \u00EEn ultimele 7 zile (mm)",
      weather_error: "Datele meteo sunt temporar indisponibile. Te rugăm să încerci din nou mai târziu.",
      footer: "F\u0103cut cu grij\u0103 pentru culeg\u0103torii de pretutindeni. Nu este un ghid de teren \u2014 verific\u0103 mereu cu un expert.",
      season: "Sezon",
      temperature: "Temperatur\u0103",
      rain: "Ploaie",
      timing: "Timp",
      check_terrain: "Verifică terenul",
      terrain_ideal: "Teren excelent pentru această specie!",
      terrain_partial: "Teren acceptabil — nu ideal, dar posibil.",
      terrain_bad: "Teren nepotrivit pentru această specie.",
      terrain_unknown: "Compatibilitatea terenului necunoscută.",
      days_since_rain: "zile de la ploaie"
    }
  }.freeze

  def self.t(key, lang = "en", replacements = {})
    text = TRANSLATIONS.dig(lang, key) || TRANSLATIONS.dig("en", key) || key.to_s
    replacements.each do |k, v|
      text = text.gsub("%{#{k}}", v.to_s)
    end
    text
  end

  def self.available_languages
    { "en" => "EN", "ro" => "RO" }
  end
end
