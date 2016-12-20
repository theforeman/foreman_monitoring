class Monitoring
  delegate :logger, :to => :Rails
  attr_reader :proxy, :proxy_api

  def initialize(opts)
    @proxy = opts.fetch(:monitoring_proxy)
    @proxy_api = ProxyAPI::Monitoring.new(:url => proxy.url)
  end

  def set_downtime_host(host, options = {})
    proxy_api.create_host_downtime(host.fqdn, { :author => 'Foreman', :comment => 'triggered by Foreman' }.merge(options))
  end
end
