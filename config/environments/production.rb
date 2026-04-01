require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false
  config.active_support.deprecation = :notify
  config.active_support.disallowed_deprecations = :log
  config.log_level = :info
  config.assets.compile = true
  config.force_ssl = true
  config.assume_ssl = true
  config.log_tags = [:request_id]

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new($stdout)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end
end
