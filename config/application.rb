require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module UpshiftNetwork
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # set up testing
    config.generators do |g|
      g.stylesheets false
      g.javascripts false
      g.test_framework :rspec,
        :fixtures => true,
        :routing_specs => false,
        :controller_specs => false,
        :request_specs => false
      g.fixture_replacement :factory_girl, :dir => "spec/factories"

    end

  end
end
