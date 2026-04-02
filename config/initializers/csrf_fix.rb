# Disable CSRF verification for stateless app behind Nginx reverse proxy.
# The app has no sessions or authentication — all requests are stateless API-style form POSTs.
Rails.application.config.action_controller.default_protect_from_forgery = false
