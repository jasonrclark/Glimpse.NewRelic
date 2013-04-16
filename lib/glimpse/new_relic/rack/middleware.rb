require 'rack'
require 'cgi'
require 'securerandom'

module Glimpse::NewRelic
  module Rack
    class Middleware
      ASSETS_PATH = File.expand_path('../../../../../assets', __FILE__)

      attr_reader :log

      def initialize(app, options = {})
        @app = app
        @log = Logger.new(STDERR)
        @providers = [
          Glimpse::NewRelic::Providers::AgentConfig.new,
          Glimpse::NewRelic::Providers::Logging.new,
          Glimpse::NewRelic::Providers::Metrics.new,
          Glimpse::NewRelic::Providers::Request.new,
          Glimpse::NewRelic::Providers::RailsConfig.new,
          Glimpse::NewRelic::Providers::SqlStatements.new,
          Glimpse::NewRelic::Providers::TransactionTrace.new
        ]
      end

      def call(env)
        req = ::Rack::Request.new(env)
        case req.path_info
        when /^\/glimpse\/assets\//
          env["PATH_INFO"].gsub!(/^\/glimpse\/assets/, '')
          return ::Rack::File.new(ASSETS_PATH).call(env)
        when /^\/glimpse/
          glimpse_method = req.path_info.gsub(/^\/glimpse\//, '')
          query_params = CGI::parse(req.query_string)
          request_uuid = query_params['request_id'].first
          response_body, contentType = self.send(glimpse_method, request_uuid, env)
          return [200, { 'Content-Type' => contentType }, [response_body]]
        else
          pass_on_to_app(req, env)
        end
      end

      # yuck
      def round_numbers(root)
        indicies = case root
        when Array then (0...root.size).to_a
        when Hash  then root.keys
        end
        if indicies
          indicies.each do |i|
            o = root[i]
            case o
            when Float
              root[i] = o.round(3)
            when Hash, Array
              round_numbers(o)
            end
          end
        end
      end

      def request_info(request_uuid, env)
        request_info = {
          'requestId' => request_uuid,
          'data' => {}
        }
        @providers.map do |provider|
          provider.data_for_request(request_uuid, request_info)
        end
        round_numbers(request_info['data'])
        request_json = request_info.to_json
        ["glimpse.data.initData(#{request_json});", "application/javascript"]
      end

      def popup(request_uuid, _)
        html = <<EOH
  <html>
  <head><title>Glimpse Popup</title></head>
  <body class="glimpse-popup">
    #{build_javascript_tag(:src => "/glimpse/assets/javascripts/client.js")}
    #{build_javascript_tag(:src => "/glimpse/assets/javascripts/metadata.js")}
    #{build_javascript_tag(:src => "/glimpse/request_info?request_id=#{request_uuid}")}
  </body>
  </html>
EOH

        [html, "text/html"]
      end

      def pass_on_to_app(req, env)
        request_uuid = SecureRandom.uuid
        Thread.current[:new_relic_request_uuid] = request_uuid

        begin_request(env, request_uuid)
        status, headers, response = @app.call(env)

        if should_inject_client?(status, headers)
          original_body = read_response_body(response)
          instrumented_body = inject_javascript(original_body, headers,
                                                build_javascript_tag(:src => "/glimpse/assets/javascripts/client.js"),
                                                build_javascript_tag(:src => "/glimpse/assets/javascripts/metadata.js"),
                                                build_javascript_tag(:src => "/glimpse/request_info?request_id=#{request_uuid}"))
          response = ::Rack::Response.new(instrumented_body, status, headers)
          response.finish
        end
        notify_providers(env, request_uuid, status, headers, response)
        [status, headers, response]
      end

      def begin_request(env, request_uuid)
        @providers.each do |provider|
          provider.begin_request(env, request_uuid)
        end
      end

      def notify_providers(env, request_uuid, status, headers, response)
        @providers.each do |provider|
          provider.notice_request(env, request_uuid, status, headers, response)
        end
      end

      def should_inject_client?(status, headers)
        status == 200 && headers["Content-Type"] && headers["Content-Type"].include?("text/html") &&
          !headers['Content-Disposition'].to_s.include?('attachment')
      end

      def read_response_body(response)
        body = ''
        response.each { |chunk| body << chunk.to_s }
        response.close if response.respond_to?(:close)
        body
      end

      def inject_javascript(rsp, headers, *tags)
        if rsp.index("<body") && (body_close = rsp.rindex("</body>"))
          rsp = rsp[0..(body_close-1)] << tags.join("\n") << rsp[body_close..-1]
          headers['Content-Length'] = rsp.length.to_s if headers['Content-Length']
        else
          log.warn("Did not find body tags to inject into")
        end
        rsp
      end

      def build_javascript_tag(attrs)
        tag = "<script "
        attr_strings = []
        attrs.each do |key, val|
          attr_strings << "#{key}=\"#{val}\""
        end
        tag << attr_strings.join(" ")
        tag << "></script>"
        tag
      end
    end
  end
end
