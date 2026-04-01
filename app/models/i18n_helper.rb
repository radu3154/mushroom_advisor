class I18nHelper
  TRANSLATIONS = {
    "en" => {
      header_title: "Mushroom Advisor",
      header_subtitle: "Should you go foraging today? Let the weather decide.",
      pick_mushroom: "Pick your mushroom",
      choose_location: "Choose your location",
      country_placeholder: "Country",
      city_placeholder: "City",
      region_placeholder: "Foraging area",
      check_conditions: "Check Conditions",
      hint_both: "Select a mushroom and location to get started",
      hint_mushroom: "Now pick a mushroom above",
      hint_location: "Now choose your foraging location",
      hint_ready: "Ready! Checking %{species} conditions near %{region}",
      back_link: "Pick a different mushroom",
      best_time: "Best time to go:",
      what_data_says: "What the data says",
      where_to_look: "Where to look",
      foraging_tips: "Foraging tips",
      currently: "Currently:",
      humidity: "humidity",
      rainfall_chart: "Rainfall last 10 days (mm)",
      weather_error: "Weather data is temporarily unavailable. Please try again later.",
      footer: "Made with care for foragers everywhere. Not a field guide \u2014 always verify with an expert.",
      season: "Season",
      temperature: "Temperature",
      rain: "Rain",
      timing: "Timing",
      days_since_rain: "days since rain",
      romania: "Romania"
    },
    "ro" => {
      header_title: "Sfatul Ciupercarului",
      header_subtitle: "Mergi la ciuperci azi? Las\u0103 vremea s\u0103 decid\u0103.",
      pick_mushroom: "Alege ciuperca",
      choose_location: "Alege loca\u021Bia",
      country_placeholder: "\u021Aara",
      city_placeholder: "Ora\u0219ul",
      region_placeholder: "Zona de cules",
      check_conditions: "Verific\u0103 Condi\u021Biile",
      hint_both: "Alege o ciuperc\u0103 \u0219i o loca\u021Bie pentru a \u00EEncepe",
      hint_mushroom: "Acum alege o ciuperc\u0103 de mai sus",
      hint_location: "Acum alege zona de cules",
      hint_ready: "Gata! Verific condi\u021Biile pentru %{species} l\u00E2ng\u0103 %{region}",
      back_link: "Alege alt\u0103 ciuperc\u0103",
      best_time: "Cel mai bun moment:",
      what_data_says: "Ce spun datele",
      where_to_look: "Unde s\u0103 cau\u021Bi",
      foraging_tips: "Sfaturi de cules",
      currently: "\u00CEn prezent:",
      humidity: "umiditate",
      rainfall_chart: "Precipita\u021Bii \u00EEn ultimele 10 zile (mm)",
      weather_error: "Datele meteo sunt temporar indisponibile. Te rugăm să încerci din nou mai târziu.",
      footer: "F\u0103cut cu grij\u0103 pentru culeg\u0103torii de pretutindeni. Nu este un ghid de teren \u2014 verific\u0103 mereu cu un expert.",
      season: "Sezon",
      temperature: "Temperatur\u0103",
      rain: "Ploaie",
      timing: "Timp",
      days_since_rain: "zile de la ploaie",
      romania: "Rom\u00E2nia"
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
