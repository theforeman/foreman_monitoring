# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api, :defaults => { :format => 'json' } do
    scope '(:apiv)', :module => :v2,
                     :defaults => { :apiv => 'v2' },
                     :apiv => /v1|v2/,
                     :constraints => ApiConstraints.new(:version => 2, default: true) do
      resources :monitoring_results, :only => [:create]
      resources :downtime, :only => [:create]
      resources :hosts, param: :host_id, only: [] do
        member do
          scope 'monitoring' do
            resources :results, controller: :hosts_monitoring_results, as: :host_monitoring_results, only: [:index]
          end
        end
      end
    end
  end

  scope '/monitoring' do
    constraints(:id => %r{[^\/]+}) do
      resources :hosts, :only => [] do
        member do
          put 'downtime'
        end
        collection do
          post :select_multiple_downtime
          post :update_multiple_downtime
          post :select_multiple_monitoring_proxy
          post :update_multiple_monitoring_proxy
        end
      end
    end
  end
end
