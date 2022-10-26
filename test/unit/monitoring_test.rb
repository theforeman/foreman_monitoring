# frozen_string_literal: true

require 'test_plugin_helper'

class MonitoringTest < ActiveSupport::TestCase
  setup do
    User.current = FactoryBot.build(:user, :admin)
    disable_monitoring_orchestration
  end

  let(:monitoring_proxy) { FactoryBot.create(:smart_proxy, :monitoring) }
  let(:host) { FactoryBot.create(:host, :managed, :with_monitoring, :monitoring_proxy => monitoring_proxy) }
  let(:monitoring) { Monitoring.new(:monitoring_proxy => monitoring_proxy) }

  test '#set_downtime_host should call proxy api' do
    ProxyAPI::Monitoring.any_instance.expects(:create_host_downtime).returns({}).once
    monitoring.set_downtime_host(host)
  end

  test '#query_host should call proxy api' do
    ProxyAPI::Monitoring.any_instance.expects(:query_host).returns({}).once
    monitoring.query_host(host)
  end
end
