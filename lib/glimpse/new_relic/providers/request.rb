require 'pp'

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


        def filter_request_hash(request)
          request.delete('rack.logger')
          request.delete('rack.errors')
          request.delete('rack.input')
          request.delete_if { |key, _| key.match(/^action_.*\./) }
          request
        end

        def data_for_request(request_uuid)
          {
            'data' => filter_request_hash(@requests[request_uuid].dup),
            'name' => 'Request'
          }
        end
      end
    end
  end
end