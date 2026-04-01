require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "action_controller/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "sprockets/railtie"
require "rails/test_unit/railtie"

module MushroomAdvisor
  class Application < Rails::Application
    config.load_defaults 7.1
    config.eager_load_paths << Rails.root.join("app/services")
  end
end
