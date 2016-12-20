module ForemanMonitoring
  module HostExtensions
    extend ActiveSupport::Concern
    included do
      before_destroy :downtime_host_destroy
      after_build :downtime_host_build

      alias_method_chain :smart_proxy_ids, :monitoring_proxy
      alias_method_chain :hostgroup_inherited_attributes, :monitoring

      has_many :monitoring_results, :dependent => :destroy, :foreign_key => 'host_id'
    end

    def monitoring_status(options = {})
      @monitoring_status ||= get_status(HostStatus::MonitoringStatus).to_status(options)
    end

    def monitoring_status_label(options = {})
      @monitoring_status_label ||= get_status(HostStatus::MonitoringStatus).to_label(options)
    end

    def refresh_monitoring_status
      get_status(HostStatus::MonitoringStatus).refresh
    end

    def downtime_host_build
      downtime_host(:comment => _('Host rebuilt in Foreman'))
    end

    def downtime_host_destroy
      downtime_host(:comment => _('Host deleted in Foreman'))
    end

    def downtime_host(options)
      return unless monitored?
      begin
        monitoring = Monitoring.new(:monitoring_proxy => monitoring_proxy)
        monitoring.set_downtime_host(self, options)
      rescue ProxyAPI::ProxyException => e
        errors.add(:base, _("Error setting downtime: '%s'") % e.message)
      end
      errors.empty?
    end

    def monitored?
      monitoring_proxy.present?
    end

    def hostgroup_inherited_attributes_with_monitoring
      hostgroup_inherited_attributes_without_monitoring + [:monitoring_proxy_id]
    end

    def smart_proxy_ids_with_monitoring_proxy
      ids = smart_proxy_ids_without_monitoring_proxy
      [monitoring_proxy, hostgroup.try(:monitoring_proxy)].compact.each do |proxy|
        ids << proxy.id
      end
      ids
    end
  end
end
