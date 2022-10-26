# frozen_string_literal: true

require 'test_plugin_helper'

class MonitoringStatusTest < ActiveSupport::TestCase
  setup do
    disable_monitoring_orchestration
  end

  let(:host) { FactoryBot.create(:host, :with_monitoring) }
  let(:status) { HostStatus::MonitoringStatus.new(:host => host) }

  context 'status changes' do
    test '#to_status should change when monitoring results change' do
      FactoryBot.create(:monitoring_result, :ok, :host => host)
      assert_equal HostStatus::MonitoringStatus::OK, status.to_status

      FactoryBot.create(:monitoring_result, :warning, :host => host)
      assert_equal HostStatus::MonitoringStatus::WARNING, status.to_status

      FactoryBot.create(:monitoring_result, :unknown, :host => host)
      assert_equal HostStatus::MonitoringStatus::WARNING, status.to_status

      FactoryBot.create(:monitoring_result, :critical, :host => host)
      assert_equal HostStatus::MonitoringStatus::CRITICAL, status.to_status
    end

    test '#to_status should be warning with critical acknowledged' do
      FactoryBot.create(:monitoring_result, :critical, :acknowledged, :host => host)
      assert_equal HostStatus::MonitoringStatus::WARNING, status.to_status
    end

    test '#to_status should be ok with critical in downtime' do
      FactoryBot.create(:monitoring_result, :critical, :downtime, :host => host)
      assert_equal HostStatus::MonitoringStatus::OK, status.to_status
    end

    test '#to_global should change when monitoring results change' do
      FactoryBot.create(:monitoring_result, :ok, :host => host)
      status.refresh
      assert_equal HostStatus::Global::OK, status.to_global

      FactoryBot.create(:monitoring_result, :warning, :host => host)
      status.refresh
      assert_equal HostStatus::Global::WARN, status.to_global

      FactoryBot.create(:monitoring_result, :unknown, :host => host)
      status.refresh
      assert_equal HostStatus::Global::WARN, status.to_global

      FactoryBot.create(:monitoring_result, :critical, :host => host)
      status.refresh
      assert_equal HostStatus::Global::ERROR, status.to_global
    end
  end

  context 'status with host with monitoring results' do
    let(:host) { FactoryBot.create(:host, :with_monitoring, :with_monitoring_results) }

    test '#relevant? is only for hosts not in build mode' do
      host.build = false
      assert status.relevant?

      host.build = true
      assert_not status.relevant?
    end

    test '#host_known_in_monitoring? should be true' do
      assert status.host_known_in_monitoring?
    end

    test '#host_monitored? should be true' do
      assert status.host_monitored?
    end
  end

  context 'status with host without monitoring results' do
    test '#relevant? is always false when build changes' do
      host.build = false
      assert_not status.relevant?

      host.build = true
      assert_not status.relevant?
    end

    test '#refresh! refreshes the date and persists the record' do
      status.expects(:refresh)
      status.refresh!

      assert status.persisted?
    end

    test '#host_known_in_monitoring? should be false' do
      assert_not status.host_known_in_monitoring?
    end
  end
end
