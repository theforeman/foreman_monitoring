module ForemanMonitoring
  module HostExtensions
    def self.prepended(base)
      base.class_eval do
        include Orchestration::Monitoring

        after_build :downtime_host_build

        has_many :monitoring_results, :dependent => :destroy, :foreign_key => 'host_id', :inverse_of => :host
      end
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

    def downtime_host(options)
      return unless monitored?
      begin
        monitoring.set_downtime_host(self, options)
      rescue ProxyAPI::ProxyException => e
        errors.add(:base, _("Error setting downtime: '%s'") % e.message)
      end
      errors.empty?
    end

    def monitored?
      monitoring_proxy.present?
    end

    def hostgroup_inherited_attributes
      super + ['monitoring_proxy_id']
    end

    def smart_proxy_ids
      ids = super
      [monitoring_proxy, hostgroup.try(:monitoring_proxy)].compact.each do |proxy|
        ids << proxy.id
      end
      ids
    end

    def monitoring_attributes
      {
        :ip => ip,
        :ip6 => ip6,
        :architecture => architecture.try(:name),
        :os => operatingsystem.try(:to_label),
        :osfamily => operatingsystem.try(:family),
        :virtual => provider != 'BareMetal',
        :provider => provider,
        :compute_resource => compute_resource.try(:to_label),
        :hostgroup => hostgroup.try(:to_label),
        :organization => organization.try(:name),
        :location => organization.try(:name),
        :comment => comment,
        :environment => environment.try(:to_s),
        :owner_name => owner.try(:name)
      }
    end

    private

    def monitoring
      Monitoring.new(:monitoring_proxy => monitoring_proxy)
    end
  end
end
