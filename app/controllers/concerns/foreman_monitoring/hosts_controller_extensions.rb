module ForemanMonitoring
  module HostsControllerExtensions
    extend ActiveSupport::Concern

    included do
      before_action :find_resource_with_monitoring, :only => [:downtime]
      before_action :find_multiple_with_monitoring, :only => %i[select_multiple_downtime update_multiple_downtime
                                                                select_multiple_monitoring_proxy update_multiple_monitoring_proxy]
      before_action :validate_host_downtime_params, :only => [:downtime]
      before_action :validate_hosts_downtime_params, :only => [:update_multiple_downtime]
      before_action :validate_multiple_monitoring_proxy, :only => :update_multiple_monitoring_proxy

      alias_method :find_resource_with_monitoring, :find_resource
      alias_method :find_multiple_with_monitoring, :find_multiple
      alias_method_chain :update_multiple_power_state, :monitoring
    end

    def downtime
      unless @host.downtime_host(downtime_options)
        process_error(:redirect => host_path, :error_msg => @host.errors.full_messages.to_sentence)
        return false
      end
      process_success :success_msg => _('Created downtime for %s') % @host, :success_redirect => :back
    end

    def select_multiple_downtime; end

    def update_multiple_downtime
      failed_hosts = {}

      @hosts.each do |host|
        unless host.monitored?
          failed_hosts[host.name] = _('is not monitored')
          next
        end
        begin
          unless host.downtime_host(downtime_options)
            error_message = host.errors.full_messages.to_sentence
            failed_hosts[host.name] = error_message
            logger.error "Failed to set a host downtime for #{host}: #{error_message}"
          end
        rescue => error
          failed_hosts[host.name] = error
          Foreman::Logging.exception(_('Failed to set a host downtime for %s.') % host, error)
        end
      end

      if failed_hosts.empty?
        notice _('A downtime was set for the selected hosts.')
      else
        error n_('A downtime clould not be set for host: %s.',
                 'A downtime could not be set for hosts: %s.',
                 failed_hosts.count) % failed_hosts.map { |h, err| "#{h} (#{err})" }.to_sentence
      end
      redirect_back_or_to hosts_path
    end

    def validate_multiple_monitoring_proxy
      validate_multiple_proxy(select_multiple_monitoring_proxy_hosts_path)
    end

    def select_multiple_monitoring_proxy; end

    def update_multiple_monitoring_proxy
      update_multiple_proxy(_('Monitoring'), :monitoring_proxy=)
    end

    def update_multiple_power_state_with_monitoring
      options = {
        :comment => 'Power state changed in Foreman',
        :author => "Foreman User #{User.current}",
        :start_time => Time.current.to_i,
        :end_time => Time.current.advance(:minutes => 30).to_i
      }
      if User.current.allowed_to?(:controller => :hosts, :action => :select_multiple_downtime) && params[:power][:set_downtime]
        @hosts.each do |host|
          unless host.monitored?
            logger.debug "Not setting a downtime for #{host} as it is not monitored."
            next
          end
          if host.downtime_host(options)
            logger.debug "Set a host downtime for #{host}."
          else
            logger.error "Failed to set a host downtime for #{host}: #{host.errors.full_messages.to_sentence}"
          end
        end
      end
      update_multiple_power_state_without_monitoring
    end

    private

    def downtime_options
      {
        :comment => params[:downtime][:comment],
        :author => "Foreman User #{User.current}",
        :start_time => Time.zone.parse(params[:downtime][:starttime]).to_i,
        :end_time => Time.zone.parse(params[:downtime][:endtime]).to_i
      }
    end

    def validate_host_downtime_params
      validate_downtime_params(host_path)
    end

    def validate_hosts_downtime_params
      validate_downtime_params(hosts_path)
    end

    def validate_downtime_params(redirect_url)
      if params[:downtime].blank? || (params[:downtime][:comment]).blank?
        process_error(:redirect => redirect_url, :error_msg => 'No comment for downtime set!')
        return false
      end
      if (params[:downtime][:starttime]).blank? || (params[:downtime][:endtime]).blank?
        process_error(:redirect => redirect_url, :error_msg => 'No start/endtime for downtime!')
        return false
      end
      starttime = Time.zone.parse(params[:downtime][:starttime])
      endtime = Time.zone.parse(params[:downtime][:endtime])
      if starttime.nil? || endtime.nil? || starttime >= endtime
        process_error(:redirect => redirect_url, :error_msg => 'Invalid start/endtime for downtime!')
        return false
      end
      true
    end

    def action_permission
      case params[:action]
      when 'downtime', 'select_multiple_downtime', 'update_multiple_downtime'
        :downtime
      when 'select_multiple_monitoring_proxy', 'update_multiple_monitoring_proxy'
        :edit
      else
        super
      end
    end
  end
end
