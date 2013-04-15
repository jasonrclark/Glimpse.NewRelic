require "glimpse/new_relic/version"
require "glimpse/new_relic/rack/middleware"
require "glimpse/new_relic/providers/request"
require "glimpse/new_relic/providers/agent_config"

module Glimpse
  module NewRelic
    def self.startup
      rails_config.middleware.use Glimpse::NewRelic::Rack::Middleware unless rails_config.nil?
    end

    def self.rails_config
      if defined?(::Rails) && ::Rails.respond_to?(:configuration)
        ::Rails.configuration
      else
        puts "No Rails? Gotta install your own Glimpse::NewRelic::Rack::Middleware :("
        nil
      end
    end
  end
end

if Rails::VERSION::MAJOR.to_i >= 3
  module NewRelic
    class Railtie < Rails::Railtie
      initializer "glimpse-new_relic.init" do |app|
        Glimpse::NewRelic.startup
      end
    end
  end
end
