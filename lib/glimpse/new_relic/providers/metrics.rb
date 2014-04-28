module Glimpse
  module NewRelic
    module Providers
      class Metrics < Base

        def self.valid?
          has_newrelic?
        end

        def initialize
          @metrics = {}
          ::NewRelic::Agent.instance.events.subscribe(:transaction_finished) do |payload|
            @metrics[Thread.current[:new_relic_request_uuid]] = payload[:metrics]
          end
        end

        def transaction_metrics_table(request_uuid)
          rows = [['Name', 'Scope', 'Call Count', 'Total Time (ms)', 'Mean Time (ms)']]
          stats_hash = @metrics[request_uuid]
          return rows unless stats_hash
          stats_hash.sort_by{|k,v| k.name + k.scope}.each do |metric_spec, stats|
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
