# frozen_string_literal: true

module Api
  module V2
    class HostsMonitoringResultsController < ::Api::V2::BaseController
      include ::Api::Version2

      api :GET, "/hosts/:host_id/monitoring/results", N_('Get the monitoring results')
      param :host_id, :identifier_dottable, required: true
      def index
        @monitoring_results = resource_scope
      end

      private

      def resource_class
        MonitoringResult
      end

      def resource_scope(*args)
        # TODO: only show for hosts with monitoring enabled?
        resource_class.authorized(:view_monitoring_results).where(host_id: params[:host_id])
      end
    end
  end
end
