# frozen_string_literal: true

module ForemanMonitoring
  module HostsHelper
    def monitoring_hosts_multiple_actions
      actions = []
      if authorized_for(:controller => :hosts, :action => :select_multiple_downtime)
        actions << { action: [_('Set downtime'), select_multiple_downtime_hosts_path], priority: 1000 }
      end
      if authorized_for(:controller => :hosts, :action => :select_multiple_monitoring_proxy)
        actions << { action: [_('Change Monitoring Proxy'), select_multiple_monitoring_proxy_hosts_path], priority: 1000 }
      end
        
      actions
    end

    def host_title_actions(host)
      title_actions(
        button_group(
          display_link_if_authorized(
            _('Downtime'),
            hash_for_host_path(:id => host).merge(
              :auth_object => host,
              :permission => :manage_downtime_hosts,
              :anchor => 'set_host_downtime'
            ),
            :class => 'btn btn-default',
            :disabled => !host.monitored?,
            :title => _('Set a downtime for this host'),
            :id => 'host-downtime',
            :data => {
              :toggle => 'modal',
              :target => '#set_host_downtime',
            }
          )
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
