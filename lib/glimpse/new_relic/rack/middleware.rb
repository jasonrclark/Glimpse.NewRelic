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
          Glimpse::NewRelic::Providers::Request.new,
          Glimpse::NewRelic::Providers::AgentConfig.new,
          Glimpse::NewRelic::Providers::TransactionTrace.new,
          Glimpse::NewRelic::Providers::SqlStatements.new,
          Glimpse::NewRelic::Providers::Metrics.new
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
          response_body = self.send(glimpse_method, request_uuid)
          return [200, { 'Content-Type' => 'application/javascript' }, [response_body]]
        else
          pass_on_to_app(req, env)
        end
      end

      def request_info(request_uuid)
        request_info = {
          "clientId" => 'whatevs',
          'contentType' => 'whatever',
          'data' => {}
        }
        @providers.map do |provider|
          request_info['data'][provider.name] = provider.data_for_request(request_uuid)
        end
        request_json = request_info.to_json
        "glimpse.data.initData(#{request_json});"
      end

      def pass_on_to_app(req, env)
        request_uuid = SecureRandom.uuid
        Thread.current[:new_relic_request_uuid] = request_uuid
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
