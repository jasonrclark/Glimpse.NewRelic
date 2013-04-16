require 'new_relic/agent'

module Glimpse
  module NewRelic
    module Providers
      class Logging < Base

        def self.valid?
          has_rails?
        end

        def begin_request(*_)
          if (::Rails.logger.class != CapturingLogger)
            @logger = CapturingLogger.new
            ::Rails.logger = @logger
          end
        end

        def data_for_request(request_uuid, request_info)
          request_info['data'][self.name] =
          {
            'data' => [["Level", "Message"]] + @logger.latest_data.reverse,
            'name' => 'Rails Log'
          }
        end
      end

      class CapturingLogger
        def initialize
          @log = ::Rails.logger
          @capture = []
        end

        def latest_data
          @capture.last(40).map { |(level, msg)| [level, msg.strip] }
        end

        def fatal(*msgs)
          @capture << ["FATAL", "#{msgs.join("\n")}"] unless msgs == [""]
          @log.fatal(*msgs)
        end

        def error(*msgs)
          @capture << ["ERROR", "#{msgs.join("\n")}"] unless msgs == [""]
          @log.error(*msgs)
        end

        def warn(*msgs)
          @capture << ["WARN", "#{msgs.join("\n")}"] unless msgs == [""]
          @log.warn(*msgs)
        end

        def info(*msgs)
          @capture << ["INFO", "#{msgs.join("\n")}"] unless msgs == [""]
          @log.info(*msgs)
        end

        def debug(*msgs)
          @capture << ["DEBUG", "#{msgs.join("\n")}"] unless msgs == [""]
          @log.debug(*msgs)
        end

        def method_missing(meth, *args, &block)
          @log.send(meth, *args, &block)
        end
      end
    end
  end
end
