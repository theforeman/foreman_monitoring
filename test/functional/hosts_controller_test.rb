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
end
