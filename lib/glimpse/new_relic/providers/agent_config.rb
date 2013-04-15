require 'new_relic/agent'

module Glimpse
  module NewRelic
    module Providers
      class AgentConfig
        def notice_request(*_)
        end

        def data_for_request(_)
          {
            'data' => [["Key", "Value", "Source"]] + apply_sources(::NewRelic::Agent.config.flattened.sort),
            'name' => 'Agent Config'
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