# frozen_string_literal: true

module ForemanMonitoring
  module NicExtensions
    extend ActiveSupport::Concern

    included do
      before_validation :move_monitoring_flag
    end

    private

    def move_monitoring_flag
      return unless host && monitoring?

      host.interfaces
          .select { |interface| interface.monitoring? && interface != self }
          .each { |interface| interface.monitoring = false }
      host.drop_monitoring_interface_cache if host.respond_to?(:drop_monitoring_interface_cache)
    end
  end
end
