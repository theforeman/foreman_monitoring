module Orchestration::Monitoring
  extend ActiveSupport::Concern

  included do
    after_validation :queue_monitoring
    before_destroy :queue_monitoring_destroy
  end

  protected

  def queue_monitoring
    return unless monitored? && errors.empty?

    clear_monitoring_object
    !monitoring_object.key?(:attrs) ? queue_monitoring_create : queue_monitoring_update
  end

  def queue_monitoring_create
    return true unless ::Monitoring.create_action?(:create)

    queue.create(:name => _('Create monitoring object for %s') % self, :priority => 20,
                 :action => [self, :setMonitoring])
  end

  def queue_monitoring_update
    return unless monitoring_update_required?(monitoring_object[:attrs], monitoring_attributes)

    Rails.logger.debug('Detected a change to the monitoring object is required.')
    return unless ::Monitoring.create_action?(:create)

    queue.create(:name => _('Monitoring update for %s') % old, :priority => 2,
                 :action => [self, :setMonitoringUpdate])
  end

  def queue_monitoring_destroy
    return unless monitored? && errors.empty?

    if ::Monitoring.delete_action?(:delete)
      queue.create(:name => _('Removing monitoring object for %s') % self, :priority => 2,
                   :action => [self, :delMonitoring])
    end
    return unless ::Monitoring.delete_action?(:downtime)

    queue.create(:name => _('Set monitoring downtime for %s') % self, :priority => 2,
                 :action => [self, :setMonitoringDowntime])
  end

  def setMonitoring
    Rails.logger.info "Adding Monitoring object for #{name}"
    monitoring.create_host(self)
  rescue StandardError => e
    failure format(_("Failed to create a monitoring object %{name}: %{message}\n "), :name => name, :message => e.message), e
  end

  def delMonitoring
    Rails.logger.info "Deleting Monitoring object for #{name}"
    monitoring.delete_host(self)
  rescue StandardError => e
    failure format(_("Failed to delete a monitoring object %{name}: %{message}\n "), :name => name, :message => e.message), e
  end

  def setMonitoringUpdate
    Rails.logger.info "Updating Monitoring object for #{name}"
    monitoring.update_host(self)
  rescue StandardError => e
    failure format(_("Failed to update a monitoring object %{name}: %{message}\n "), :name => name, :message => e.message), e
  end

  def delMonitoringUpdate; end

  def setMonitoringDowntime
    Rails.logger.info "Setting Monitoring downtime for #{name}"
    monitoring.set_downtime_host(self, monitoring_downtime_defaults)
  rescue StandardError => e
    failure format(_("Failed to set a monitoring downtime for %{name}: %{message}\n "), :name => name, :message => e.message), e
  end

  def delMonitoringDowntime
    Rails.logger.info "Deleting Monitoring downtime for #{name}"
    monitoring.del_downtime_host(self, monitoring_downtime_defaults)
  rescue StandardError => e
    failure format(_("Failed to set a monitoring downtime for %{name}: %{message}\n "), :name => name, :message => e.message), e
  end

  def monitoring_object
    @monitoring_object || monitoring.query_host(self)
  end

  def clear_monitoring_object
    @monitoring_object = nil
    true
  end

  private

  def monitoring_downtime_defaults
    {
      :comment => _('Host deleted in Foreman')
    }
  end

  def monitoring_update_required?(actual_attrs, desired_attrs)
    return true if actual_attrs.deep_symbolize_keys.keys != desired_attrs.deep_symbolize_keys.keys

    actual_attrs.deep_symbolize_keys.merge(desired_attrs.deep_symbolize_keys) do |k, actual_v, desired_v|
      if actual_v.is_a?(Hash) && desired_v.is_a?(Hash)
        return true if monitoring_update_required?(actual_v, desired_v)
      elsif actual_v.to_s != desired_v.to_s
        Rails.logger.debug "Scheduling monitoring host object update because #{k} changed it's value from '#{actual_v}' (#{actual_v.class}) to '#{desired_v}' (#{desired_v.class})"
        return true
      end
      desired_v
    end
    Rails.logger.debug 'No monitoring update required.'
    false
  end
end
