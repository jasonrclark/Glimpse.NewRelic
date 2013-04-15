module Glimpse
  module NewRelic
    module Providers
      class Base
        def initialize
        end

        def name
          self.class.name.split("::").last
        end

        def begin_request(env, request_uuid)
        end

        def notice_request(env, request_uuid, status, headers, response)
        end

        def data_for_request
          {}
        end
      end
    end
  end
end
