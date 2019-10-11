# frozen_string_literal: true

require 'test_plugin_helper'

class HostTest < ActiveSupport::TestCase
  setup do
    User.current = FactoryBot.build(:user, :admin)
    setup_settings
    disable_orchestration
    disable_monitoring_orchestration
  end

  context 'downtime handling' do
    let(:host) { FactoryBot.create(:host, :managed) }

    test 'it should set a downtime when build status changes' do
      host.expects(:downtime_host).once

      host.build = false
      assert host.save
      host.build = true
      assert host.save
    end
  end

  context 'a host with monitoring orchestration' do
    let(:host) { FactoryBot.build(:host, :managed, :with_monitoring) }

    context 'with create/delete actions' do
      setup do
        Setting[:monitoring_create_action] = 'create'
        Setting[:monitoring_delete_action] = 'delete'
      end

      test 'should queue monitoring create' do
        ProxyAPI::Monitoring.any_instance.stubs(:query_host).returns(nil)
        assert_valid host
        tasks = host.queue.all.map(&:name)
        assert_includes tasks, "Create monitoring object for #{host}"
        assert_equal 1, tasks.size
      end

      test 'should queue monitoring update' do
        fake_host_query_result = {
          'ip' => '1.1.1.1',
          'ip6' => '2001:db8::1'
        }
        ProxyAPI::Monitoring.any_instance.stubs(:query_host).returns(fake_host_query_result)
        host.save
        host.queue.clear
        assert_valid host
        tasks = host.queue.all.map(&:name)
        assert_includes tasks, "Monitoring update for #{host}"
        assert_equal 1, tasks.size
      end

      test 'should not queue monitoring update' do
        ProxyAPI::Monitoring.any_instance.stubs(:query_host).returns({})
        host.save
        host.queue.clear
        fake_host_query_result = host.monitoring_attributes
        ProxyAPI::Monitoring.any_instance.stubs(:query_host).returns(fake_host_query_result)
        assert_valid host
        tasks = host.queue.all.map(&:name)
        assert_equal [], tasks
      end

      test 'should queue monitoring destroy' do
        assert_valid host
        host.queue.clear
        host.send(:queue_monitoring_destroy)
        tasks = host.queue.all.map(&:name)
        assert_includes tasks, "Removing monitoring object for #{host}"
        assert_equal 1, tasks.size
      end
    end

    context 'with none/downtime actions' do
      setup do
        Setting[:monitoring_create_action] = 'none'
        Setting[:monitoring_delete_action] = 'downtime'
      end

      test 'should not queue monitoring create actions' do
        assert_valid host
        tasks = host.queue.all.map(&:name)
        assert_equal [], tasks
      end

      test 'should queue monitoring downtime on host destroy' do
        assert_valid host
        host.queue.clear
        host.send(:queue_monitoring_destroy)
        tasks = host.queue.all.map(&:name)
        assert_includes tasks, "Set monitoring downtime for #{host}"
        assert_equal 1, tasks.size
      end

      test 'should set downtime on delete with correct hostname' do
        assert host.save
        host.queue.clear
        host.stubs(:skip_orchestration?).returns(false) # Enable orchestration
        ProxyAPI::Monitoring.any_instance.expects(:create_host_downtime).with(host.name, anything).returns(true).once
        assert host.destroy
      end
    end

    test 'setMonitoring' do
      ProxyAPI::Monitoring.any_instance.expects(:create_host).once
      host.send(:setMonitoring)
    end

    test 'delMonitoring' do
      ProxyAPI::Monitoring.any_instance.expects(:delete_host).once
      host.send(:delMonitoring)
    end

    test 'setMonitoringDowntime' do
      ProxyAPI::Monitoring.any_instance.expects(:create_host_downtime).once
      host.send(:setMonitoringDowntime)
    end

    test 'delMonitoringDowntime' do
      ProxyAPI::Monitoring.any_instance.expects(:remove_host_downtime).once
      host.send(:delMonitoringDowntime)
    end
  end

  context 'a host without monitoring' do
    let(:host) { FactoryBot.build(:host, :managed) }

    test 'should not queue any monitoring actions' do
      assert_valid host
      host.queue.clear
      host.send(:queue_monitoring)
      host.send(:queue_monitoring_destroy)
      tasks = host.queue.all.map(&:name)
      assert_equal [], tasks
    end
  end
end
