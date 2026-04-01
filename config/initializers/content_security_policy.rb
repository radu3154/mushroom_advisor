# Be sure to restart your server when you modify this file.

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.font_src    :self, "https://fonts.gstatic.com"
    policy.img_src     :self, "https://images.unsplash.com", :data
    policy.script_src  :self, :unsafe_inline
    policy.style_src   :self, :unsafe_inline, "https://fonts.googleapis.com"
  end
end
