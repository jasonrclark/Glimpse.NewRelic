require 'new_relic/agent'

module Glimpse
  module NewRelic
    module Providers
      class Logging < Base

        def begin_request(*_)
          if (::Rails.logger.class != CapturingLogger)
            @logger = CapturingLogger.new
            ::Rails.logger = @logger
          end
        end

        def data_for_request(request_uuid)
          {
            'data' => [["Level", "Message"]] + @logger.latest_data.reverse,
            'name' => 'Latest Logs'
          }
        end
      end

      class CapturingLogger
        def initialize
          @log = ::Rails.logger
          @capture = []
        end

        def latest_data
          @capture.last(40)
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
      end
    end
  end
end