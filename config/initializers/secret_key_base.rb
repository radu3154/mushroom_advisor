Rails.application.config.secret_key_base = ENV.fetch("SECRET_KEY_BASE") {
  # Auto-generate for development. Set a real one in production.
  require "securerandom"
  SecureRandom.hex(64)
}
