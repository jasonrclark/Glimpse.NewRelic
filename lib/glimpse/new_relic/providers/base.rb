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

        def end_request(env, request_uuid, status, headers, response, duration)
        end

        def data_for_request(*args)
        end
      end
    end
  end
end
