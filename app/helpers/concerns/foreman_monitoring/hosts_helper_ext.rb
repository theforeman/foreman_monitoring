module ForemanMonitoring
  module HostsHelperExt
    extend ActiveSupport::Concern

    included do
      alias_method_chain :host_title_actions, :monitoring
      alias_method_chain :multiple_actions, :monitoring
    end

    def multiple_actions_with_monitoring
      return multiple_actions_without_monitoring unless authorized_for(:controller => :hosts, :action => :select_multiple_downtime)
      multiple_actions_without_monitoring + [[_('Set downtime'), select_multiple_downtime_hosts_path]]
    end

    def host_title_actions_with_monitoring(host)
      title_actions(
        button_group(
          display_link_if_authorized(_('Downtime'),
                                     hash_for_host_path(:id => host).merge(:auth_object => host,
                                                                           :permission => :manage_host_downtimes,
                                                                           :anchor => 'set_host_downtime'),
                                     :class => 'btn btn-default',
                                     :disabled => !host.monitored?,
                                     :title    => _('Set a downtime for this host'),
                                     :id       => 'host-downtime',
                                     :data     => { :toggle => 'modal',
                                                    :target => '#set_host_downtime'
                                                  }
                                    )
        )
      )
      host_title_actions_without_monitoring(host)
    end

    def host_monitoring_result_icon_class(result)
      icon_class = case result
                   when :ok
                     'pficon-ok'
                   when :warning
                     'pficon-info'
                   when :critical
                     'pficon-error-circle-o'
                   else
                     'pficon-help'
                   end

      "host-status #{icon_class} #{host_monitoring_result_class(result)}"
    end

    def host_monitoring_result_class(result)
      case result
      when :ok
        'status-ok'
      when :warning
        'status-warn'
      when :critical
        'status-error'
      else
        'status-question'
      end
    end

    def datetime_f(f, attr, options = {})
      field(f, attr, options) do
        addClass options, 'form-control'
        f.datetime_local_field attr, options
      end
    end
  end
end
