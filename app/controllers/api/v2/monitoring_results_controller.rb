module Api
  module V2
    class MonitoringResultsController < V2::BaseController
      include Api::Version2
      include Foreman::Controller::SmartProxyAuth

      add_smart_proxy_filters :create, :features => 'Monitoring'

      api :POST, '/monitoring_results', N_('Import monitoring result')
      param :host, String, :desc => N_('FQDN of the host that the results are for'), :required => true
      param :service, String, :desc => N_('Name of the service the results belong to'), :required => true
      param :timestamp, String, :desc => N_('Timestamp of the results')
      param :acknowledged, [true, false], :desc => N_('Is the result acknowledged?')
      param :downtime, [true, false], :desc => N_('Is the result in downtime?')
      param :result, [0, 1, 2, 3],
            :desc => N_('State of the monitoring result (0 -> ok, 1 -> warning, 2 -> critical, 3 -> unknown)')

      def create
        begin
          MonitoringResult.import(monitoring_result_params.with_indifferent_access)
        rescue StandardError => e
          logger.error "Failed to import monitoring result: #{e.message}"
          logger.debug e.backtrace.join("\n")
          render :json => { 'message' => e.message }, :status => :unprocessable_entity
          return
        end

        render :json => { 'message' => 'OK' }
      end

      private

      def monitoring_result_params
        params.permit(:host, :result, :service, :acknowledged, :downtime, :timestamp, :initial)
      end
    end
  end
end
