module Glimpse
  module NewRelic
    module Providers
      class Routing < Base

        def self.valid?
          has_rails?
        end

        def data_for_request(request_uuid, request_info)
          all_routes = Rails.application.routes.routes

          require 'rails/application/route_inspector'
          inspector = Rails::Application::RouteInspector.new

          #require 'debugger'; debugger;
          data = inspector.collect_routes(all_routes)

          request_info['data'][self.name] =
          {
            'data' => data,
            'name' => 'Rails Routes'
          }
        rescue
          nil
        end
      end

    end
  end
end

