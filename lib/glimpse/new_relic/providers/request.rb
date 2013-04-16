module Glimpse
  module NewRelic
    module Providers
      class Request < Base
        def initialize
          @requests = {}
        end

        def notice_request(env, request_uuid, status, headers, response)
          @requests[request_uuid] = env.dup
        end


        def filter_request_hash(request)
          request.delete('rack.logger')
          request.delete('rack.errors')
          request.delete('rack.input')
          request.delete_if { |key, _| key.match(/^action_.*\./) }
          request
        end

        def data_for_request(request_uuid, request_info)
          request = @requests[request_uuid] || {}
          request_info['clientId'] = "Chrome 26"    # Where's this actually come from?
          request_info['contentType'] = "text/html" # TODO: Need to hold onto the response headers too
          request_info['uri'] = request["REQUEST_URI"]
          request_info['data'][self.name] =
          {
            'data' => filter_request_hash(request),
            'name' => 'Request'
          }
        end
      end
    end
  end
end
