module Glimpse
  module NewRelic
    module Providers
      class SqlStatements < Base
        def self.valid?
          has_newrelic?
        end

        def initialize
          @statements = {}
          ::NewRelic::Agent.instance.events.subscribe(:sql) do |payload|
            request_uuid = Thread.current[:new_relic_request_uuid]
            @statements[request_uuid] ||= []
            @statements[request_uuid] << payload.dup
          end
        end

        def sql_trace_table(request_uuid)
          rows = [['Duration (ms)', 'Query']]
          entries = @statements[request_uuid] || []
          entries.each do |entry|
            pretty_sql = entry[:sql].gsub("\n", ' ').gsub("\s+", ' ').strip
            rows << [entry[:duration] * 1000, pretty_sql]
          end
          rows
        end

        def data_for_request(request_uuid, request_info)
          request_info['data'][self.name] =
          {
            'data' => sql_trace_table(request_uuid),
            'name' => "SQL Statements"
          }
        end
      end
    end
  end
end
