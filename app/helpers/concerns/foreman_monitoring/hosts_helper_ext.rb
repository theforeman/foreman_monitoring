module ForemanMonitoring
  module HostsHelperExt
    extend ActiveSupport::Concern

    # included do
    #  alias_method_chain :host_title_actions, :monitoring
    # end

    # def host_title_actions_with_monitoring(host)
    #  title_actions(
    #    button_group(
    #      link_to(_('Monitoring'), monitoring_show_host_path(host), :target => '_blank', :class => 'btn btn-default')
    #    )
    #  )
    #  host_title_actions_without_monitoring(host)
    # end

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
  end
end
