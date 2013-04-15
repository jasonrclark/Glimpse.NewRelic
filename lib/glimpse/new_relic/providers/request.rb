module Glimpse
  module NewRelic
    module Providers
      class Request
        def initialize
          @requests = {}
        end

        def notice_request(env, request_uuid, status, headers, response)
          @requests[request_uuid] = env.dup
        end

        def data_for_request(request_uuid)
          request = @requests[request_uuid]
          {
            'data' => { 'user_agent' => ::Rack::Request.new(request).user_agent },
            'name' => 'Request'
          }
        end
      end
    end
  end
end