
module Glimpse
  module NewRelic
    module Providers
      class History < Base

        def initialize
          @requests = []
        end

        def end_request(env, request_uuid, status, headers, response, duration)
          parent_request_id = env["HTTP_GLIMPSE_PARENT_REQUESTID"]
          @requests << {
            "clientId" => "Chrome 34",
            "dateTime" => Time.now.to_s,
            "duration" => duration,
            "parentRequestId" => parent_request_id,
            "requestId" => request_uuid,
            "isAjax" => !parent_request_id.nil?,
            "method" => env["REQUEST_METHOD"],
            "uri" => env["REQUEST_URI"],
            "contentType" => headers["Content-Type"],
            "statusCode" => status,
            "userAgent" => env["HTTP_USER_AGENT"]
          }
        end


        def requests
          {
            "Chrome 34" => @requests.dup
          }
        end

        def requests_for_parent(parent_request_id)
          @requests.select {|r| r["parentRequestId"] == parent_request_id && r["isAjax"]}
        end

      end
    end
  end
end
