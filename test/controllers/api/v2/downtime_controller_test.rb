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
