module ForemanMonitoring
  module HostsControllerExtensions
    extend ActiveSupport::Concern

    included do
      before_action :find_resource_with_monitoring, :only => [:downtime]
      before_action :validate_downtime_params, :only => [:downtime]
      alias_method :find_resource_with_monitoring, :find_resource
    end

    def downtime
      options = {
        :comment => params[:downtime][:comment],
        :author => "Foreman User #{User.current}",
        :start_time => DateTime.parse(params[:downtime][:starttime]).to_time.to_i,
        :end_time => DateTime.parse(params[:downtime][:endtime]).to_time.to_i
      }
      unless @host.downtime_host(options)
        process_error(:redirect => host_path, :error_msg => @host.errors.full_messages.to_sentence)
        return false
      end
      process_success :success_msg => _('Created downtime for %s') % (@host), :success_redirect => :back
    end

    private

    def validate_downtime_params
      if params[:downtime].blank? || (params[:downtime][:comment]).blank?
        process_error(:redirect => host_path, :error_msg => 'No comment for downtime set!')
        return false
      end
      if (params[:downtime][:starttime]).blank? || (params[:downtime][:endtime]).blank?
        process_error(:redirect => host_path, :error_msg => 'No start/endtime for downtime!')
        return false
      end
      begin
        DateTime.parse(params[:downtime][:starttime])
        DateTime.parse(params[:downtime][:endtime])
      rescue ArgumentError
        process_error(:redirect => host_path, :error_msg => 'Invalid start/endtime for downtime!')
        return false
      end
    end

    def action_permission
      case params[:action]
      when 'downtime'
        :downtime
      else
        super
      end
    end
  end
end
