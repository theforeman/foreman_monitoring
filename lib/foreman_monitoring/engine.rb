# frozen_string_literal: true

require 'deface'

module ForemanMonitoring
  class Engine < ::Rails::Engine
    engine_name 'foreman_monitoring'

    config.autoload_paths += Dir["#{config.root}/app/controllers/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/helpers/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/models/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/services"]

    # Add any db migrations
    initializer 'foreman_monitoring.load_app_instance_data' do |app|
      ForemanMonitoring::Engine.paths['db/migrate'].existent.each do |path|
        app.config.paths['db/migrate'] << path
      end
    end

    initializer 'foreman_monitoring.register_plugin', :before => :finisher_hook do |_app|
      Foreman::Plugin.register :foreman_monitoring do
        requires_foreman '>= 3.0'

        settings do
          category(:monitoring, N_('Monitoring')) do
            setting('monitoring_affect_global_status',
                    type: :boolean,
                    description: N_("Monitoring status will affect a host's global status when enabled"),
                    default: true,
                    full_name: N_('Monitoring status should affect global status'))
            setting('monitoring_create_action',
                    type: :string,
                    description: N_('What action should be taken when a host is created'),
                    default: 'create',
                    full_name: N_('Host Create Action'),
                    collection: proc { ::Monitoring::CREATE_ACTIONS })
            setting('monitoring_delete_action',
                    type: :string,
                    description: N_('What action should be taken when a host is deleted'),
                    default: 'delete',
                    full_name: N_('Host Delete Action'),
                    collection: proc { ::Monitoring::DELETE_ACTIONS })
          end
        end

        apipie_documented_controllers ["#{ForemanMonitoring::Engine.root}/app/controllers/api/v2/*.rb"]

        security_block :foreman_monitoring do
          permission :view_monitoring_results,
                     {},
                     :resource_type => 'Host'
          permission :manage_downtime_hosts,
                     { :hosts => [:downtime, :select_multiple_downtime, :update_multiple_downtime], :'api/v2/downtime' => [:create] },
                     :resource_type => 'Host'
          permission :upload_monitoring_results,
                     :'api/v2/monitoring_results' => [:create]
        end

        # Extend built in permissions
        Foreman::AccessControl.permission(:edit_hosts).actions.concat [
          'hosts/select_multiple_monitoring_proxy',
          'hosts/update_multiple_monitoring_proxy'
        ]

        role 'Monitoring viewer', [:view_monitoring_results], 'Role granting permissions to view monitor results'
        role 'Monitoring manager', [:view_monitoring_results, :manage_downtime_hosts], 'Role granting permissions to view monitor results and manage downtimes'

        register_custom_status HostStatus::MonitoringStatus

        add_controller_action_scope('HostsController', :index) { |base_scope| base_scope.includes(:monitoring_results) }

        monitoring_proxy_options = {
          :feature => 'Monitoring',
          :label => N_('Monitoring Proxy'),
          :description => N_('Monitoring Proxy to use to manage monitoring of this host'),
          :api_description => N_('ID of Monitoring Proxy to use to manage monitoring of this host')
        }

        # add monitoring smart proxy to hosts and hostgroups
        smart_proxy_for Host::Managed, :monitoring_proxy, monitoring_proxy_options
        smart_proxy_for Hostgroup, :monitoring_proxy, monitoring_proxy_options

        add_controller_action_scope('HostsController', :index) { |base_scope| base_scope.includes(:monitoring_proxy) }
      end
    end

    config.to_prepare do
      ::Host::Managed.prepend(ForemanMonitoring::HostExtensions)
      ::Hostgroup.include(ForemanMonitoring::HostgroupExtensions)
      ::HostsHelper.prepend(ForemanMonitoring::HostsHelperExt)
      ::HostsController.prepend(ForemanMonitoring::HostsControllerExtensions)
    rescue StandardError => e
      Rails.logger.warn "ForemanMonitoring: skipping engine hook (#{e})"
    end

    initializer 'foreman_monitoring.register_gettext', after: :load_config_initializers do |_app|
      locale_dir = File.join(File.expand_path('../..', __dir__), 'locale')
      locale_domain = 'foreman_monitoring'
      Foreman::Gettext::Support.add_text_domain locale_domain, locale_dir
    end
  end
end
