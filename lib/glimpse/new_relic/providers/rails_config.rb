require 'new_relic/agent'

module Glimpse
  module NewRelic
    module Providers
      class RailsConfig < Base

        def self.valid?
          has_rails?
        end

        def data_for_request(_, request_info)
          request_info['data'][self.name] =
            {
            'data' => [["Key", "Value"]] + get_configuration,
            'name' => 'Rails Config'
          }
        end

        def get_configuration
          data = {}
          Rails.configuration.as_json.each do |k, v|
            data[k.to_s] = v.inspect
          end
          data.sort
        end
      end
    end
  end
end

