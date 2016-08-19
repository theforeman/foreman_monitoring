module Api
  module V2
    class MonitoringResultsController < V2::BaseController
      include Api::Version2
      include Foreman::Controller::SmartProxyAuth

      add_smart_proxy_filters :create, :features => 'Monitoring'

      def create
        begin
          MonitoringResult.import(monitoring_result_params.with_indifferent_access)
        rescue => e
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
