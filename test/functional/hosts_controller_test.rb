require 'test_plugin_helper'

class HostsControllerExtensionsTest < ActionController::TestCase
  tests ::HostsController
  setup do
    User.current = users(:admin)
    @host = FactoryGirl.create(:host, :managed)
  end

  context 'when setting a host downtime' do
    setup do
      @request.env['HTTP_REFERER'] = host_path(:id => @host)
    end

    test 'the flash should inform it' do
      Host::Managed.any_instance.stubs(:downtime_host).returns(true)
      put :downtime, {
        :id => @host.name,
        :downtime => {
          :comment => 'Maintenance work.',
          :starttime => DateTime.now,
          :endtime => DateTime.now
        }
      }, set_session_user
      assert_response :found
      assert_redirected_to host_path(:id => @host)
      assert_nil flash[:error]
      assert_not_nil flash[:notice]
      assert_equal "Created downtime for #{@host}", flash[:notice]
    end

    test 'with missing comment param the flash should inform it' do
      put :downtime, { :id => @host.name }, set_session_user
      assert_response :found
      assert_redirected_to host_path(:id => @host)
      assert_not_nil flash[:error]
      assert_equal 'No comment for downtime set!', flash[:error]
    end

    test 'with missing date params the flash should inform it' do
      put :downtime, { :id => @host.name, :downtime => { :comment => 'Maintenance work.' } }, set_session_user
      assert_response :found
      assert_redirected_to host_path(:id => @host)
      assert_not_nil flash[:error]
      assert_equal 'No start/endtime for downtime!', flash[:error]
    end

    test 'with invalid starttime the flash should inform it' do
      put :downtime, {
        :id => @host.name,
        :downtime => {
          :comment => 'Maintenance work.',
          :starttime => 'invalid',
          :endtime => 'invalid' }
      }, set_session_user
      assert_response :found
      assert_redirected_to host_path(:id => @host)
      assert_not_nil flash[:error]
      assert_equal 'Invalid start/endtime for downtime!', flash[:error]
    end
  end

  describe 'setting a downtime on multiple hosts' do
    before do
      @hosts = FactoryGirl.create_list(:host, 2, :with_puppet)
      @hosts.each do |host|
        FactoryGirl.create(:monitoring_result, :ok, :host => host)
      end
      @request.env['HTTP_REFERER'] = hosts_path
    end

    test 'should set a downtime' do
      Host::Managed.any_instance.expects(:downtime_host).twice.returns(true)
      params = {
        :host_ids => @hosts.map(&:id),
        :downtime => {
          :comment => 'Maintenance work.',
          :starttime => DateTime.now,
          :endtime => DateTime.now
        }
      }

      post :update_multiple_downtime, params,
           set_session_user

      assert_response :found
      assert_redirected_to hosts_path
      assert_nil flash[:error]
      assert_not_nil flash[:notice]
      assert_equal 'A downtime was set for the selected hosts.', flash[:notice]
    end
  end

  describe 'changing the power state on multiple hosts' do
    before do
      @hosts = FactoryGirl.create_list(:host, 2, :with_puppet)
      @hosts.each do |host|
        FactoryGirl.create(:monitoring_result, :ok, :host => host)
      end
      @request.env['HTTP_REFERER'] = hosts_path

      power_mock = mock('power')
      power_mock.expects(:poweroff).twice
      Host::Managed.any_instance.stubs(:power).returns(power_mock)
    end

    test 'should set a downtime if selected' do
      Host::Managed.any_instance.expects(:downtime_host).twice.returns(true)
      params = {
        :host_ids => @hosts.map(&:id),
        :power => {
          :action => 'poweroff',
          :set_downtime => true
        }
      }

      post :update_multiple_power_state, params,
           set_session_user

      assert_response :found
      assert_redirected_to hosts_path
      assert_nil flash[:error]
      assert_not_nil flash[:notice]
      assert_equal 'The power state of the selected hosts will be set to poweroff', flash[:notice]
    end

    test 'should not set a downtime if not selected' do
      Host::Managed.any_instance.expects(:downtime_host).never
      params = {
        :host_ids => @hosts.map(&:id),
        :power => {
          :action => 'poweroff',
          :set_downtime => false
        }
      }

      post :update_multiple_power_state, params,
           set_session_user

      assert_response :found
      assert_redirected_to hosts_path
      assert_nil flash[:error]
      assert_not_nil flash[:notice]
      assert_equal 'The power state of the selected hosts will be set to poweroff', flash[:notice]
    end
  end
end
