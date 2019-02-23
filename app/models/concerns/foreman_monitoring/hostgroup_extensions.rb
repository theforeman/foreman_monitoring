module ForemanMonitoring
  module HostgroupExtensions
    extend ActiveSupport::Concern

    def monitoring_proxy
      return super if ancestry.blank?

      SmartProxy.find_by(id: inherited_monitoring_proxy_id)
    end

    def inherited_monitoring_proxy_id
      return monitoring_proxy_id if ancestry.blank?

      self[:monitoring_proxy_id] || self.class.sort_by_ancestry(ancestors.where('monitoring_proxy_id is not NULL')).last.try(:monitoring_proxy_id)
    end
  end
end
