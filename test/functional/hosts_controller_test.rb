require 'test_plugin_helper'

class HostsControllerExtensionsTest < ActionController::TestCase
  tests ::HostsController
  setup do
    User.current = users(:admin)
    disable_monitoring_orchestration
    ProxyAPI::Monitoring.stubs(:create_host).returns(true)
    ProxyAPI::Monitoring.stubs(:update_host).returns(true)
    ProxyAPI::Monitoring.stubs(:delete_host).returns(true)
    @host = FactoryBot.create(:host, :managed)
  end

  context 'when setting a host downtime' do
    setup do
      @request.env['HTTP_REFERER'] = host_path(:id => @host)
    end

    test 'the flash should inform it' do
      Host::Managed.any_instance.stubs(:downtime_host).returns(true)
      put :downtime,
          params: {
            :id => @host.name,
            :downtime => {
              :comment   => 'Maintenance work.',
              :starttime => Time.current,
              :endtime   => Time.current.advance(:hours => 2)
            }
          },
          session: set_session_user
      assert_response :found
      assert_redirected_to host_path(:id => @host)
      assert_nil flash[:error]
      assert_not_nil flash[:success]
      assert_equal "Created downtime for #{@host}", flash[:success]
    end

    test 'with missing comment param the flash should inform it' do
      put :downtime, params: { :id => @host.name }, session: set_session_user
      assert_response :found
      assert_redirected_to host_path(:id => @host)
      assert_not_nil flash[:error]
      assert_equal 'No comment for downtime set!', flash[:error]
    end

    test 'with missing date params the flash should inform it' do
      put :downtime,
          params: { :id => @host.name, :downtime => { :comment => 'Maintenance work.' } },
          session: set_session_user
      assert_response :found
      assert_redirected_to host_path(:id => @host)
      assert_not_nil flash[:error]
      assert_equal 'No start/endtime for downtime!', flash[:error]
    end

    test 'with invalid starttime the flash should inform it' do
      put :downtime,
          params: {
            :id => @host.name,
            :downtime => {
              :comment   => 'Maintenance work.',
              :starttime => 'invalid',
              :endtime   => 'invalid'
            }
          },
          session: set_session_user
      assert_response :found
      assert_redirected_to host_path(:id => @host)
      assert_not_nil flash[:error]
      assert_equal 'Invalid start/endtime for downtime!', flash[:error]
    end

    test 'should parse the times in the correct time zone' do
      User.current.timezone = 'Berlin'
      User.current.save
      Host::Managed.any_instance.expects(:downtime_host).with(has_entries(:start_time => 1_492_676_100, :end_time => 1_492_683_300))
      put :downtime,
          params: {
            :id => @host.name,
            :downtime => {
              :comment   => 'Maintenance work.',
              :starttime => '2017-04-20T10:15',
              :endtime   => '2017-04-20T12:15'
            }
          },
          session: set_session_user
    end
  end

  describe 'setting a downtime on multiple hosts' do
    before do
      @hosts = FactoryBot.create_list(:host, 2, :with_monitoring)
      @request.env['HTTP_REFERER'] = hosts_path
    end

    test 'show a host selection' do
      host_ids = @hosts.map(&:id)
      post :select_multiple_downtime,
           params: { :host_ids => host_ids },
           session: set_session_user,
           xhr: true
      assert_response :success
      assert_includes response.body, @hosts.first.name
      assert_includes response.body, @hosts.last.name
    end

    test 'should set a downtime' do
      Host::Managed.any_instance.expects(:downtime_host).twice.returns(true)
      params = {
        :host_ids => @hosts.map(&:id),
        :downtime => {
          :comment => 'Maintenance work.',
          :starttime => Time.current,
          :endtime => Time.current.advance(:hours => 2)
        }
      }

      post :update_multiple_downtime, params: params, session: set_session_user

      assert_response :found
      assert_redirected_to hosts_path
      assert_nil flash[:error]
      assert_not_nil flash[:success]
      assert_equal 'A downtime was set for the selected hosts.', flash[:success]
    end
  end

  describe 'changing the power state on multiple hosts' do
    before do
      @hosts = FactoryBot.create_list(:host, 2, :with_monitoring)
      @request.env['HTTP_REFERER'] = hosts_path

      power_mock = mock('power')
      power_mock.expects(:poweroff).twice
      Host::Managed.any_instance.stubs(:power).returns(power_mock)
      Host::Managed.any_instance.stubs(:supports_power?).returns(true)
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

      post :update_multiple_power_state, params: params, session: set_session_user

      assert_response :found
      assert_redirected_to hosts_path
      assert_nil flash[:error]
      assert_not_nil flash[:success]
      assert_equal 'The power state of the selected hosts will be set to poweroff', flash[:success]
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

      post :update_multiple_power_state, params: params, session: set_session_user

      assert_response :found
      assert_redirected_to hosts_path
      assert_nil flash[:error]
      assert_not_nil flash[:success]
      assert_equal 'The power state of the selected hosts will be set to poweroff', flash[:success]
    end
  end

  describe 'changing the monitoring proxy of multiple hosts' do
    let(:hosts) { FactoryBot.create_list(:host, 2, :with_monitoring) }
    let(:monitoring_proxy) { FactoryBot.create(:smart_proxy, :monitoring, :organizations => [hosts.first.organization], :locations => [hosts.first.location]) }
    before do
      @request.env['HTTP_REFERER'] = hosts_path
    end

    test 'show a host selection' do
      host_ids = hosts.map(&:id)
      post :select_multiple_monitoring_proxy,
           params: { :host_ids => host_ids },
           session: set_session_user,
           xhr: true
      assert_response :success
      hosts.each do |host|
        assert response.body =~ /#{host.name}/m
      end
    end

    test 'should change the proxy' do
      hosts.each do |host|
        assert_not_equal monitoring_proxy, host.monitoring_proxy
      end

      params = {
        :host_ids => hosts.map(&:id),
        :proxy => { :proxy_id => monitoring_proxy.id }
      }

      post :update_multiple_monitoring_proxy, params: params, session: set_session_user

      assert_response :found
      assert_redirected_to hosts_path
      assert_nil flash[:error]
      assert_equal "The Monitoring proxy of the selected hosts was set to #{monitoring_proxy.name}", flash[:success]

      hosts.each do |host|
        as_admin do
          assert_equal monitoring_proxy, host.reload.monitoring_proxy
        end
      end
    end
  end
end
