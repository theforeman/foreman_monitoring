require 'test_helper'

class ProxyApiDhcpTest < ActiveSupport::TestCase
  def setup
    @url = 'http://localhost:8443'
    @monitoring = ProxyAPI::Monitoring.new({ :url => @url })
  end

  test 'constructor should complete' do
    assert_not_nil @monitoring
  end

  test 'base url should equal /monitoring' do
    assert_equal "#{@url}/monitoring", @monitoring.url
  end

  test 'create_host_downtime should do post' do
    @monitoring.expects(:post).with({}, 'downtime/host/example.com').
      returns(fake_rest_client_response({ 'result' => {} }))
    assert_equal({ 'result' => {} }, @monitoring.create_host_downtime('example.com'))
  end
end
