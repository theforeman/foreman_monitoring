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

  test '#set_downtime_host should use configured default duration' do
    start_time = Time.utc(2026, 9, 26, 12).to_i
    Time.stubs(:now).returns(Time.at(start_time).utc)
    Setting[:monitoring_default_downtime_duration] = 30
    expected_options = {
      :author => 'Foreman',
      :comment => 'triggered by Foreman',
      :start_time => start_time,
      :end_time => start_time + (30 * 60),
    }
    ProxyAPI::Monitoring.any_instance.expects(:create_host_downtime).with(host.name, expected_options).returns({}).once

    monitoring.set_downtime_host(host)
  end

  test '#set_downtime_host should preserve an explicit period' do
    Setting[:monitoring_default_downtime_duration] = 30
    period = {
      :start_time => Time.utc(2026, 9, 26, 12).to_i,
      :end_time => Time.utc(2026, 9, 26, 14).to_i,
    }
    expected_options = {
      :author => 'Foreman',
      :comment => 'triggered by Foreman',
    }.merge(period)
    ProxyAPI::Monitoring.any_instance.expects(:create_host_downtime).with(host.name, expected_options).returns({}).once

    monitoring.set_downtime_host(host, period)
  end

  test '#query_host should call proxy api' do
    ProxyAPI::Monitoring.any_instance.expects(:query_host).returns({}).once
    monitoring.query_host(host)
  end
end
