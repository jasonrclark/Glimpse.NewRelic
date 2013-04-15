require 'new_relic/agent'

module Glimpse
  module NewRelic
    module Providers
      class AgentConfig
        def notice_request(*_)
        end

        def data_for_request(_)
          {
            'data' => ::NewRelic::Agent.config.flattened.sort,
            'name' => 'Agent Config'
          }
        end
      end
    end
  end
end
