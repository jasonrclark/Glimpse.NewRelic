
module Glimpse
  module NewRelic
    module Providers
      class History < Base

        def initialize
          @requests = []
        end

        def notice_request(env, request_uuid, status, headers, response)
          @requests << {
            "clientId" => "Chrome 21",
            "dateTime" => Time.now.to_s,
            "duration" => 0.0,
            "parentRequestId" => nil,
            "requestId" => request_uuid,
            "isAjax" => false,
            "method" => env["REQUEST_METHOD"],
            "uri" => env["REQUEST_URI"],
            "contentType" => headers["Content-Type"],
            "statusCode" => status,
            "userAgent" => env["HTTP_USER_AGENT"]
          }
        end


        def requests
          {
            "Chrome 21" => @requests.dup
          }
        end

      end
    end
  end
end
