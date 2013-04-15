module Glimpse
  module NewRelic
    module Providers
      class TransactionTrace < Base
        COLOR_MAP = {
          'ROOT'         => ["#AF78DD", "#823BBE"],
          'ActiveRecord' => ["#F0ED5D", "#DEE81A"],
          'Controller'   => ["#FDBF45", "#DDA431"],
          'View'         => ["#10E309", "#0EC41D"]
        }

        OTHER_COLORS = [
          ["#EEEEEE", "#CCCCCC"], # other
          ["#72A3E4", "#5087CF"]  # filter
        ]

        def initialize
          @traces = {}
        end

        def name
          "glimpse_timeline"
        end

        def notice_request(env, request_uuid, status, headers, response)
          @traces[request_uuid] = ::NewRelic::Agent::TransactionInfo.get.transaction.transaction_trace
        end

        def seconds_to_milliseconds(t)
          t * 1000
        end

        def category_for_segment(segment)
          segment.metric_name.split('/').first
        end

        def transaction_trace_to_timeline(trace)
          events = []
          root_segment = trace.root_segment
          trace.each_segment do |segment|
            events << {
              'title' => segment.metric_name,
              'category' => category_for_segment(segment),
              'startTime' => Time.at(segment.entry_timestamp).strftime("%m/%d/%Y %H:%M:%S"),
              'details' => {},
              'duration' => seconds_to_milliseconds(segment.exit_timestamp - segment.entry_timestamp),
              'startPoint' => seconds_to_milliseconds(segment.entry_timestamp)
            }
          end

          category_names = events.map { |e| e['category'] }.uniq

          categories = {}
          category_names.map do |name|
            categories[name] = {}
            colors = COLOR_MAP[name] || OTHER_COLORS.sample
            categories[name]['eventColor'] = colors[0]
            categories[name]['eventColorHighlight'] = colors[1]
          end

          {
            'duration' => seconds_to_milliseconds(root_segment.duration),
            'category' => categories,
            'events' => events
          }
        end

        def data_for_request(request_uuid)
          trace = @traces[request_uuid]
          {
            'data' => transaction_trace_to_timeline(trace),
            'name' => 'Transaction Trace'
          }
        end
      end
    end
  end
end