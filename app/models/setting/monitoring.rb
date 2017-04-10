class Setting
  class Monitoring < ::Setting

    def self.default_settings
      [
        set('monitoring_affect_global_status',
            _("Monitoring status will affect a host's global status when enabled"),
            true, N_('Monitoring status should affect global status')),
        set('monitoring_create_action',
            _("What action should be taken when a host is created"),
            'create', N_('Host Create Action'), nil, {:collection => Proc.new {::Monitoring::CREATE_ACTIONS} }),
        set('monitoring_delete_action',
            _("What action should be taken when a host is deleted"),
            'delete', N_('Host Delete Action'), nil, {:collection => Proc.new {::Monitoring::DELETE_ACTIONS} })
      ]
    end

    def self.load_defaults
      # Check the table exists
      return unless super

      self.transaction do
        default_settings.each { |s| self.create! s.update(:category => "Setting::Monitoring")}
      end

      true
    end

    def self.humanized_category
      N_('Monitoring')
    end
  end
end
