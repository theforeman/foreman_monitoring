require 'deface'

module ForemanMonitoring
  class Engine < ::Rails::Engine
    engine_name 'foreman_monitoring'

    config.autoload_paths += Dir["#{config.root}/app/controllers/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/helpers/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/models/concerns"]
    config.autoload_paths += Dir["#{config.root}/app/overrides"]
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
      rescue
        false
      end
        require_dependency File.expand_path('../../../app/models/setting/monitoring.rb', __FILE__)
      end
    end

    initializer 'foreman_monitoring.register_plugin', :before => :finisher_hook do |_app|
      Foreman::Plugin.register :foreman_monitoring do
        requires_foreman '>= 1.11'
        register_custom_status HostStatus::MonitoringStatus
      end
    end

    config.to_prepare do
      begin
        Host::Managed.send :include, ForemanMonitoring::HostExtensions
        HostsHelper.send(:include, ForemanMonitoring::HostsHelperExt)
      rescue => e
        Rails.logger.warn "ForemanMonitoring: skipping engine hook (#{e})"
      end
    end

    initializer 'foreman_monitoring.register_gettext', after: :load_config_initializers do |_app|
      locale_dir = File.join(File.expand_path('../../..', __FILE__), 'locale')
      locale_domain = 'foreman_monitoring'
      Foreman::Gettext::Support.add_text_domain locale_domain, locale_dir
    end
  end
end
