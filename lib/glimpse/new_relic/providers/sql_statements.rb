module Glimpse
  module NewRelic
    module Providers
      class SqlStatements < Base
        def initialize
          @statements = {}
          ::NewRelic::Agent.instance.events.subscribe('sql') do |sql, config, duration|
            request_uuid = Thread.current[:new_relic_request_uuid]
            @statements[request_uuid] ||= []
            @statements[request_uuid] << [sql, config, duration]
          end
        end

        def sql_trace_table(request_uuid)
          rows = [['Duration (ms)', 'Query']]
          entries = @statements[request_uuid] || []
          entries.each do |(sql, _, duration)|
            pretty_sql = sql.gsub("\n", ' ').gsub("\s+", ' ').strip
            rows << [duration * 1000, pretty_sql]
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
