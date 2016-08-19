require 'test_plugin_helper'

class HostTest < ActiveSupport::TestCase
  setup do
    User.current = FactoryGirl.build(:user, :admin)
    setup_settings
  end

  context 'downtime handling' do
    let(:host) { FactoryGirl.create(:host, :managed) }

    test 'it should set a downtime when host is deleted' do
      host.expects(:downtime_host).once
      assert host.destroy
    end

    test 'it should set a downtime when build status changes' do
      host.expects(:downtime_host).once

      host.build = false
      assert host.save
      host.build = true
      assert host.save
    end
  end
end
