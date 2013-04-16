require "glimpse/new_relic/version"
require "glimpse/new_relic/rack/middleware"
require "glimpse/new_relic/providers/base"

module Glimpse
  module NewRelic
    def self.startup
      Providers::Base.autoload_providers
    end
  end
end

if defined?(::Rails) && ::Rails::VERSION::MAJOR.to_i >= 3
  module NewRelic
    class Railtie < Rails::Railtie
      initializer "glimpse-new_relic.init" do |app|
        if defined?(::Rails) && ::Rails.respond_to?(:configuration)
          ::Rails.configuration.middleware.use Glimpse::NewRelic::Rack::Middleware unless ::Rails.configuration.nil?
          Glimpse::NewRelic.startup
        else
          puts "No Rails? Gotta install your own Glimpse::NewRelic::Rack::Middleware :("
        end
      end
    end
  end
elsif defined?(::Sinatra)
  ::Sinatra::Base.use Glimpse::NewRelic::Rack::Middleware
  Glimpse::NewRelic.startup
else
  puts "Don't know what you're running, but you can install Glimpse::NewRelic::Rack::Middleware yourself if you want"
end
