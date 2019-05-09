# frozen_string_literal: true

module Api
  module V2
    class DowntimeController < V2::BaseController
      include Api::Version2
      include ::ForemanMonitoring::FindHostByClientCert

      authorize_host_by_client_cert %i[create]
      before_action :find_host, :only => [:create]

      api :POST, '/downtime', N_('Schedule host downtime')

      def create
        begin
          @host.downtime_host(:comment => _('Host requested downtime'))
        rescue StandardError => e
          Foreman::Logging.exception('Failed to request downtime', e)
          render :json => { 'message' => e.message }, :status => :unprocessable_entity
          return
        end

        render :json => { 'message' => 'OK' }
      end

      private

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
