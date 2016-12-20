require 'test_plugin_helper'

class MonitoringTest < ActiveSupport::TestCase
  setup do
    User.current = FactoryGirl.build(:user, :admin)
    setup_settings
  end

  let(:monitoring_proxy) { FactoryGirl.create(:smart_proxy, :monitoring) }
  let(:host) { FactoryGirl.create(:host, :managed, :with_monitoring, :monitoring_proxy => monitoring_proxy) }
  let(:monitoring) { Monitoring.new(:monitoring_proxy => monitoring_proxy) }

  test '#set_downtime_host should call proxy api' do
    ProxyAPI::Monitoring.any_instance.expects(:create_host_downtime).returns({}).once
    monitoring.set_downtime_host(host)
  end
end
