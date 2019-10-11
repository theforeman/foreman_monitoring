# frozen_string_literal: true

module ForemanMonitoring
  module HostsHelperExt
    def multiple_actions
      actions = super
      actions << [_('Set downtime'), select_multiple_downtime_hosts_path] if authorized_for(:controller => :hosts, :action => :select_multiple_downtime)
      actions << [_('Change Monitoring Proxy'), select_multiple_monitoring_proxy_hosts_path] if authorized_for(:controller => :hosts, :action => :select_multiple_monitoring_proxy)
      actions
    end

    def host_title_actions(host)
      title_actions(
        button_group(
          display_link_if_authorized(_('Downtime'),
                                     hash_for_host_path(:id => host).merge(:auth_object => host,
                                                                           :permission => :manage_host_downtimes,
                                                                           :anchor => 'set_host_downtime'),
                                     :class => 'btn btn-default',
                                     :disabled => !host.monitored?,
                                     :title => _('Set a downtime for this host'),
                                     :id => 'host-downtime',
                                     :data => { :toggle => 'modal',
                                                :target => '#set_host_downtime' })
        )
      )
      super
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

    def monitoring_datetime_f(f, attr, options = {})
      field(f, attr, options) do
        addClass options, 'form-control'
        f.datetime_field attr, options
      end
    end
  end
end
