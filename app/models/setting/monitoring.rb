class Setting
  class Monitoring < ::Setting
    def self.load_defaults
      # Check the table exists
      return unless super

      Setting.transaction do
        [
          set('monitoring_affect_global_status',
              _("Monitoring status will affect a host's global status when enabled"),
              true, N_('Monitoring status should affect global status'))
        ].compact.each { |s| create! s.update(:category => 'Setting::Monitoring') }
      end
    end
  end
end
