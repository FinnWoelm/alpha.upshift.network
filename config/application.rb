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
      g.hidden_namespaces << :test_unit
      g.assets false
      g.helper false
      g.test_framework :rspec,
        :fixture => false,
        :routing_specs => false,
        :controller_specs => false,
        :request_specs => false
      g.integration_tool :rspec
      g.fixture_replacement :factory_girl, :dir => "spec/factories"

    end

    # use our own error handling
    config.exceptions_app = self.routes

    # set paperclip defaults: remove (strip) exif data on uploaded attachmens
    config.paperclip_defaults = { convert_options: {all: "-strip"} }
    config.attachment_storage_location = "/"

  end
end
