require 'rack'

module Glimpse::NewRelic
  module Rack
    class Middleware
      ASSETS_PATH = File.expand_path('../../../../../assets', __FILE__)

      attr_reader :log

      def initialize(app, options = {})
        @app = app
        @log = Logger.new(STDERR)
      end

      def call(env)
        req = ::Rack::Request.new(env)
        case req.path_info
        when /^\/glimpse\/assets\//
          env["PATH_INFO"].gsub!(/^\/glimpse\/assets/, '')
          return ::Rack::File.new(ASSETS_PATH).call(env)
        when /^\/glimpse/
          path_parts = req.path_info.split('/')
          glimpse_method = path_parts[1..-1].join('/')
          return [200, {}, ["alert('You called #{glimpse_method}');"]]
        else
          pass_on_to_app(env)
        end
      end

      def pass_on_to_app(env)
        status, headers, response = @app.call(env)

        if should_inject_client?(status, headers)
          original_body = read_response_body(response)
          instrumented_body = inject_javascript(original_body, headers,
                                                build_javascript_tag(:src => "/glimpse/assets/javascripts/client.js"),
                                                build_javascript_tag(:src => "/glimpse/assets/javascripts/metadata.js"))
          response = ::Rack::Response.new(instrumented_body, status, headers)
          response.finish
        end
        [status, headers, response]
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
