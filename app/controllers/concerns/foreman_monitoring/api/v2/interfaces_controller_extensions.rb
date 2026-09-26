# frozen_string_literal: true

module ForemanMonitoring
  module Api
    module V2
      module InterfacesControllerExtensions
        extend Apipie::DSL::Concern

        update_api(:create, :update) do
          param :interface, Hash do
            param :monitoring, :bool, :desc => N_('Should this interface be used for monitoring?')
          end
        end
      end
    end
  end
end
