module HostStatus
  class MonitoringStatus < HostStatus::Status
    OK = 0
    WARNING = 1
    CRITICAL = 2
    UNKNOWN = 3

    def relevant?(_options = {})
      host_not_in_build? && host_known_in_monitoring?
    end

    def to_status(_options = {})
      state = OK
      grouped_results.each do |resultset, _count|
        result, downtime, acknowledged = resultset
        next if downtime
        result = WARNING if acknowledged || result == UNKNOWN
        state = result if result > state
      end
      state
    end

    def to_global(_options = {})
      return HostStatus::Global::OK unless should_affect_global_status?
      case status
      when OK
        HostStatus::Global::OK
      when WARNING
        HostStatus::Global::WARN
      when CRITICAL
        HostStatus::Global::ERROR
      else
        HostStatus::Global::WARN
      end
    end

    def self.status_name
      N_('Monitoring Status')
    end

    def to_label(_options = {})
      case status
      when OK
        N_('OK')
      when WARNING
        N_('Warning')
      when CRITICAL
        N_('Critical')
      else
        N_('Unknown')
      end
    end

    def host_not_in_build?
      host && !host.build
    end

    def host_known_in_monitoring?
      host.monitoring_results.any?
    end

    def should_affect_global_status?
      Setting[:monitoring_affect_global_status]
    end

    private

    def grouped_results
      host.monitoring_results.group([:result, :downtime, :acknowledged]).count
    end
  end
end
