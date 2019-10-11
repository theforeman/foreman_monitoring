# frozen_string_literal: true

# This calls the main test_helper in Foreman-core
require 'test_helper'
require 'database_cleaner'

# Add plugin to FactoryBot's paths
FactoryBot.definition_file_paths << File.join(File.dirname(__FILE__), 'factories')
FactoryBot.reload

# Foreman's setup doesn't handle cleaning up for Minitest::Spec
DatabaseCleaner.strategy = :transaction

def setup_settings
  Setting::Monitoring.load_defaults
end

def disable_monitoring_orchestration
  ProxyAPI::Monitoring.any_instance.stubs(:query_host).returns({})
end

class Minitest::Spec
  before :each do
    DatabaseCleaner.start
  end

  after :each do
    DatabaseCleaner.clean
  end
end
