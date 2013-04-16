require 'new_relic/agent'

module Glimpse
  module NewRelic
    module Providers
      class Middlewares < Base

        def self.valid?
          has_rails?
        end

        def data_for_request(_, request_info)
          stack = Rails.configuration.middleware
          rows = stack.map do |middleware|
            args = middleware.args
            [middleware.name, args.empty? ? nil : args]
          end
          rows.unshift(['Class', 'Args'])

          request_info['data'][self.name] = {
            'data' => rows,
            'name' => 'Middleware Stack'
          }
        end
      end
    end
  end
end

