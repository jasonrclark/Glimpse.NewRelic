module Glimpse
  module NewRelic
    module Providers
      class Metrics < Base

        def self.valid?
          has_newrelic?
        end

        def initialize
          @metrics = {}
          ::NewRelic::Agent.instance.events.subscribe('transaction_metrics') do |stats|
            @metrics[Thread.current[:new_relic_request_uuid]] = stats
          end
        end

        def transaction_metrics_table(request_uuid)
          rows = [['Name', 'Scope', 'Call Count', 'Total Time (ms)', 'Mean Time (ms)']]
          stats_hash = @metrics[request_uuid]
          return rows unless stats_hash
          stats_hash.each do |metric_spec, stats|
            rows << [
              metric_spec.name,
              metric_spec.scope,
              stats.call_count,
              stats.total_call_time * 1000,
              (stats.total_call_time / stats.call_count) * 1000
            ]
          end
          rows
        end

        def data_for_request(request_uuid, request_info)
          request_info['data'][self.name] =
          {
            'data' => transaction_metrics_table(request_uuid),
            'name' => 'Transaction Metrics'
          }
        end
      end
    end
  end
end
