require 'new_relic/agent/transaction_sampler'

module NewRelic
  module Agent
    class TransactionSampler
      def notice_sql_glimpsed(sql, config, duration, &explainer)
        ::NewRelic::Agent.instance.events.notify(:sql,
                                                 :sql => sql, :duration => duration)
        notice_sql_original(sql, config, duration, &explainer)
      end

      alias_method :notice_sql_original, :notice_sql
      alias_method :notice_sql, :notice_sql_glimpsed
    end
  end
end
