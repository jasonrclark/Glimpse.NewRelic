require 'rack'

module Glimpse::NewRelic
  module Rack
    class Middleware
      def initialize(app, options = {})
        @app = app
      end

      # method required by Rack interface
      def call(env)
        @app.call(env)   # [status, headers, response]
      end
    end
  end
end
