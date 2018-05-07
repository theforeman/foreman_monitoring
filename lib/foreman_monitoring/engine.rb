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

    initializer 'foreman_monitoring.load_default_settings',
                :before => :load_config_initializers do |_app|
      if begin
        Setting.table_exists?
      rescue StandardError
        false
      end
        require_dependency File.expand_path('../../app/models/setting/monitoring.rb', __dir__)
      end
    end

    initializer 'foreman_monitoring.register_plugin', :before => :finisher_hook do |_app|
      Foreman::Plugin.register :foreman_monitoring do
        requires_foreman '>= 1.18'

        apipie_documented_controllers ["#{ForemanMonitoring::Engine.root}/app/controllers/api/v2/*.rb"]

        security_block :foreman_monitoring do
          permission :view_monitoring_results,
                     {},
                     :resource_type => 'Host'
          permission :manage_host_downtimes,
                     { :hosts => [:downtime, :select_multiple_downtime, :update_multiple_downtime] },
                     :resource_type => 'Host'
          permission :upload_monitoring_results,
                     :'api/v2/monitoring_results' => [:create]
          permission :edit_hosts,
                     { :hosts => [:select_multiple_monitoring_proxy, :update_multiple_monitoring_proxy] },
                     :resource_type => 'Host'
        end

        role 'Monitoring viewer', [:view_monitoring_results]
        role 'Monitoring manager', [:view_monitoring_results, :manage_host_downtimes]

        register_custom_status HostStatus::MonitoringStatus

        add_controller_action_scope(HostsController, :index) { |base_scope| base_scope.includes(:monitoring_results) }

        monitoring_proxy_options = {
          :feature => 'Monitoring',
          :label => N_('Monitoring Proxy'),
          :description => N_('Monitoring Proxy to use to manage monitoring of this host'),
          :api_description => N_('ID of Monitoring Proxy to use to manage monitoring of this host')
        }

        # add monitoring smart proxy to hosts and hostgroups
        smart_proxy_for Host::Managed, :monitoring_proxy, monitoring_proxy_options
        smart_proxy_for Hostgroup, :monitoring_proxy, monitoring_proxy_options

        add_controller_action_scope(HostsController, :index) { |base_scope| base_scope.includes(:monitoring_proxy) }
      end
    end

    config.to_prepare do
      begin
        ::Host::Managed.send(:prepend, ForemanMonitoring::HostExtensions)
        ::Hostgroup.send(:include, ForemanMonitoring::HostgroupExtensions)
        ::HostsHelper.send(:prepend, ForemanMonitoring::HostsHelperExt)
        ::HostsController.send(:prepend, ForemanMonitoring::HostsControllerExtensions)
      rescue StandardError => e
        Rails.logger.warn "ForemanMonitoring: skipping engine hook (#{e})"
      end
    end

    initializer 'foreman_monitoring.register_gettext', after: :load_config_initializers do |_app|
      locale_dir = File.join(File.expand_path('../..', __dir__), 'locale')
      locale_domain = 'foreman_monitoring'
      Foreman::Gettext::Support.add_text_domain locale_domain, locale_dir
    end
  end
end
