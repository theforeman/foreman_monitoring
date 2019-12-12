# frozen_string_literal: true

require 'test_plugin_helper'

class Api::V2::DowntimeControllerTest < ActionController::TestCase
  let(:host1) { as_admin { FactoryBot.create(:host, :managed) } }

  context 'with user authentication' do
    context '#create' do
      test 'should deny access' do
        put :create
        assert_response :forbidden
      end
    end
  end

  context 'with client cert' do
    setup do
      User.current = nil
      reset_api_credentials

      Setting[:ssl_client_dn_env] = 'SSL_CLIENT_S_DN'
      Setting[:ssl_client_verify_env] = 'SSL_CLIENT_VERIFY'

      @request.env['HTTPS'] = 'on'
      @request.env['SSL_CLIENT_S_DN'] = "CN=#{host1.name},DN=example,DN=com"
      @request.env['SSL_CLIENT_VERIFY'] = 'SUCCESS'
    end

    context '#create' do
      test 'should create downtime' do
        put :create
        assert_response :success
      end
    end

    context '#create with duration' do
      test 'should create downtime with given duration' do
        Host::Managed.any_instance.expects(:downtime_host).with { |params| params[:end_time] - params[:start_time] == 3600 }
        put :create, params: { duration: 3600 }
        assert_response :success
      end

      test 'should create downtime with given duration as string' do
        Host::Managed.any_instance.expects(:downtime_host).with { |params| params[:end_time] - params[:start_time] == 3600 }
        put :create, params: { duration: '3600' }
        assert_response :success
      end
    end

    context '#create with reason' do
      test 'should create downtime with given reason' do
        Host::Managed.any_instance.expects(:downtime_host).with { |params| params[:comment] == 'In testing' }
        put :create, params: { reason: 'In testing' }
        assert_response :success
      end
    end
  end

  context 'without any credentials' do
    setup do
      User.current = nil
      reset_api_credentials
    end

    context '#create' do
      test 'should deny access' do
        post :create
        assert_response :unauthorized
      end
    end
  end
end
