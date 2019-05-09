# frozen_string_literal: true

module ForemanMonitoring
  module FindHostByClientCert
    extend ActiveSupport::Concern

    module ClassMethods
      def authorize_host_by_client_cert(actions, _options = {})
        skip_before_action :require_login, :only => actions, :raise => false
        skip_before_action :authorize, :only => actions
        skip_before_action :verify_authenticity_token, :only => actions
        skip_before_action :set_taxonomy, :only => actions, :raise => false
        skip_before_action :session_expiry, :update_activity_time, :only => actions
        before_action(:only => actions) { require_client_cert_or_login }
        attr_reader :detected_host
      end
    end

    private

    # Permits Hosts authorized by their client cert
    # or a user with permission
    def require_client_cert_or_login
      @detected_host = find_host_by_client_cert

      if detected_host
        set_admin_user
        return true
      end

      require_login
      unless User.current
        render_error 'unauthorized', :status => :unauthorized unless performed? && api_request?
        return false
      end
      authorize
    end

    def find_host_by_client_cert
      hostname = get_client_cert_hostname

      return unless hostname

      host ||= Host::Base.find_by(certname: hostname) ||
               Host::Base.find_by(name: hostname)
      logger.info { "Found Host #{host} by client cert #{hostname}" } if host
      host
    end

    def get_client_cert_hostname
      verify = request.env[Setting[:ssl_client_verify_env]]
      unless verify == 'SUCCESS'
        logger.info { "Client certificate is invalid: #{verify}" }
        return
      end

      dn = request.env[Setting[:ssl_client_dn_env]]
      return unless dn && dn =~ %r{CN=([^\s\/,]+)}i

      hostname = Regexp.last_match(1).downcase
      logger.debug "Extracted hostname '#{hostname}' from client certificate."
      hostname
    end
  end
end
