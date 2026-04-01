# Be sure to restart your server when you modify this file.

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.font_src    :self, "https://fonts.gstatic.com"
    policy.img_src     :self, :data, "https://*.tile.openstreetmap.org", "https://images.unsplash.com"
    policy.script_src  :self, :unsafe_inline, "https://unpkg.com"
    policy.style_src   :self, :unsafe_inline, "https://fonts.googleapis.com", "https://unpkg.com"
    policy.connect_src :self, "https://api.open-meteo.com", "https://archive-api.open-meteo.com", "https://nominatim.openstreetmap.org"
  end
end
