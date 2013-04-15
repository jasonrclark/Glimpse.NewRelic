require 'rack'

module Glimpse::NewRelic
  module Rack
    class Middleware
      attr_reader :log

      def initialize(app, options = {})
        @app = app
        @log = Logger.new(STDERR)
      end

      GLIMPSE_PATH = /^\/glimpse\/(.*)$/

      def call(env)
        env["PATH_INFO"].match(GLIMPSE_PATH)
        glimpse_method = $1

        if $1
          return [200, {}, ["alert('You called #{glimpse_method}');"]]
        else
          pass_on_to_app(env)
        end
      end

      def pass_on_to_app(env)
        status, headers, response = @app.call(env)
        if should_inject_client?(status, headers)
          original_body = read_response_body(response)
          instrumented_body = inject_javascript_tag(original_body, headers, :src => "glimpse/client")
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

      def inject_javascript_tag(rsp, headers, attrs)
        if rsp.index("<body") && (body_close = rsp.rindex("</body>"))
          tag = build_javascript_tag(attrs)
          log.debug("Injecting tag '#{tag}' into body @ #{body_close}")
          rsp = rsp[0..(body_close-1)] << tag << rsp[body_close..-1]
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
