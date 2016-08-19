require 'test_plugin_helper'

class MonitoringTest < ActiveSupport::TestCase
  setup do
    User.current = FactoryGirl.build(:user, :admin)
    setup_settings
    @proxy = FactoryGirl.create(:smart_proxy, :monitoring)
  end

  let(:host) { FactoryGirl.create(:host, :managed) }
  let(:monitoring) { Monitoring.new }

  test '#set_downtime_host should call proxy api' do
    ProxyAPI::Monitoring.any_instance.expects(:create_host_downtime).returns({}).once
    monitoring.set_downtime_host(host)
  end
end
