# frozen_string_literal: true

module Api
  module V2
    class DowntimeController < V2::BaseController
      include Api::Version2
      include ::ForemanMonitoring::FindHostByClientCert

      authorize_host_by_client_cert %i[create]
      before_action :find_host, :only => [:create]

      api :POST, '/downtime', N_('Schedule host downtime')
      param :all_services, [true, false], :desc => N_('Set downtime for all services'), :required => false
      param :duration, :number, :desc => N_('Downtime duration (seconds)'), :required => false
      param :reason, String, :desc => N_('Downtime reason'), :required => false

      def create
        begin
          options = {
            :comment => downtime_params[:reason] || _('Host requested downtime')
          }
          options[:all_services] = downtime_params[:all_services] if downtime_params.key? :all_services
          if downtime_params.key? :duration
            options[:start_time] = Time.now.to_i
            options[:end_time] = Time.now.to_i + downtime_params[:duration].to_i
          end
          @host.downtime_host(options)
        rescue StandardError => e
          Foreman::Logging.exception('Failed to request downtime', e)
          render :json => { 'message' => e.message }, :status => :unprocessable_entity
          return
        end

        render :json => { 'message' => 'OK' }
      end

      private

      def downtime_params
        params.permit(:all_services, :duration, :reason)
      end

      def find_host
        @host = detected_host

        return true if @host

        logger.info 'Denying access because no host could be detected.'
        if User.current
          render_error 'access_denied',
                       :status => :forbidden,
                       :locals => {
                         :details => 'You need to authenticate with a valid client cert. The DN has to match a known host.'
                       }
        else
          render_error 'unauthorized',
                       :status => :unauthorized,
                       :locals => {
                         :user_login => get_client_cert_hostname
                       }
        end
      end
    end
  end
end
