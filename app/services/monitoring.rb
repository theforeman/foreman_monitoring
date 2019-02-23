class Monitoring
  CREATE_ACTIONS = {
    'none' => _('None'),
    'create' => _('Create Host Object')
  }.freeze

  DELETE_ACTIONS = {
    'none' => _('None'),
    'delete' => _('Delete Host Object'),
    'downtime' => _('Set Downtime for Host')
  }.freeze

  delegate :logger, :to => :Rails
  attr_reader :proxy, :proxy_api

  def self.create_action?(action)
    Setting[:monitoring_create_action] == action.to_s
  end

  def self.delete_action?(action)
    Setting[:monitoring_delete_action] == action.to_s
  end

  def initialize(opts)
    @proxy = opts.fetch(:monitoring_proxy)
    @proxy_api = ProxyAPI::Monitoring.new(:url => proxy.url)
  end

  def set_downtime_host(host, options = {})
    proxy_api.create_host_downtime(host.name, default_downtime_options.merge(options))
  end

  def del_downtime_host(host, options = {})
    proxy_api.remove_host_downtime(host.name, default_downtime_options.merge(options))
  end

  def create_host(host)
    proxy_api.create_host(host.name, host.monitoring_attributes)
  end

  def update_host(host)
    proxy_api.update_host(host.name, host.monitoring_attributes)
  end

  def delete_host(host)
    proxy_api.delete_host(host.name)
  end

  def query_host(host)
    result = proxy_api.query_host(host.name)
    return {} unless result

    {
      :attrs => result
    }
  end

  private

  def default_downtime_options
    {
      :author => 'Foreman',
      :comment => 'triggered by Foreman'
    }
  end
end
