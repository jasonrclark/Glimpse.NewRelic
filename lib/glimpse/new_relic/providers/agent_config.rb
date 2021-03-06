require 'new_relic/agent'

module Glimpse
  module NewRelic
    module Providers
      class AgentConfig < Base

        def self.valid?
          has_newrelic?
        end

        def data_for_request(_, request_info)
          request_info['data'][self.name] =
          {
            'data' => [["Key", "Value", "Source"]] + apply_sources(::NewRelic::Agent.config.flattened.sort),
            'name' => 'New Relic Config'
          }
        end

        def apply_sources(config)
          config.map do |key, value|
            source = ::NewRelic::Agent.config.source(key).class.name
            source = source.split('::').last
            source = source.gsub('Source', '')

            [key, value, source]
          end
        end
      end
    end
  end
end
