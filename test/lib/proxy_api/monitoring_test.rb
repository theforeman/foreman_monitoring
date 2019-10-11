# frozen_string_literal: true

require 'test_helper'

class ProxyApiMonitoringTest < ActiveSupport::TestCase
  def setup
    @url = 'http://localhost:8443'
    @monitoring = ProxyAPI::Monitoring.new(:url => @url)
  end

  test 'constructor should complete' do
    assert_not_nil @monitoring
  end

  test 'base url should equal /monitoring' do
    assert_equal "#{@url}/monitoring", @monitoring.url
  end

  test 'create_host_downtime should do post' do
    @monitoring.expects(:post).with({}, 'downtime/host/example.com')
               .returns(fake_rest_client_response('result' => {}))
    assert_equal({ 'result' => {} }, @monitoring.create_host_downtime('example.com'))
  end

  test 'remove_host_downtime should do delete' do
    @monitoring.expects(:delete).with('downtime/host/example.com?comment=bla')
               .returns(fake_rest_client_response('result' => {}))
    assert_equal({ 'result' => {} }, @monitoring.remove_host_downtime('example.com', :comment => 'bla'))
  end

  test 'create_host should do put' do
    @monitoring.expects(:put).with({ :attributes => { :ip => '1.1.1.1' } }, 'host/example.com')
               .returns(fake_rest_client_response('result' => {}))
    assert_equal({ 'result' => {} }, @monitoring.create_host('example.com', :ip => '1.1.1.1'))
  end

  test 'update_host should do post' do
    @monitoring.expects(:post).with({ :attributes => { :ip => '1.1.1.1' } }, 'host/example.com')
               .returns(fake_rest_client_response('result' => {}))
    assert_equal({ 'result' => {} }, @monitoring.update_host('example.com', :ip => '1.1.1.1'))
  end

  test 'delete_host should do delete' do
    @monitoring.expects(:delete).with('host/example.com')
               .returns(fake_rest_client_response('result' => {}))
    assert_equal({ 'result' => {} }, @monitoring.delete_host('example.com'))
  end

  test 'query_host should do get' do
    @monitoring.expects(:get).with('host/example.com')
               .returns(fake_rest_client_response('result' => {}))
    assert_equal({ 'result' => {} }, @monitoring.query_host('example.com'))
  end
end
