module ProxyAPI
  class Monitoring < ProxyAPI::Resource
    def initialize(args)
      @url = args[:url] + '/monitoring'
      super args
    end

    def create_host_downtime(host, args = {})
      parse(post(args, "downtime/host/#{host}"))
    rescue => e
      raise ProxyException.new(url, e, N_('Unable to set downtime for %s') % host)
    end
  end
end
