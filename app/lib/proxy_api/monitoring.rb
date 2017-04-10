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

    def remove_host_downtime(host, args = {})
      parse(delete("downtime/host/#{host}?#{args.to_query}"))
    rescue => e
      raise ProxyException.new(url, e, N_('Unable to remove downtime for %s') % host)
    end

    def create_host(host, attributes = {})
      parse(put({:attributes => attributes}, "host/#{host}"))
    rescue => e
      raise ProxyException.new(url, e, N_('Unable to create monitoring host object for %s') % host)
    end

    def update_host(host, attributes = {})
      parse(post({:attributes => attributes}, "host/#{host}"))
    rescue => e
      raise ProxyException.new(url, e, N_('Unable to update monitoring host object for %s') % host)
    end

    def delete_host(host)
      raise Foreman::Exception.new('Missing hostname.') if host.blank?
      parse(delete("host/#{host}"))
    rescue RestClient::ResourceNotFound
      true
    rescue => e
      raise ProxyException.new(url, e, N_('Unable to delete monitoring host object for %s') % host)
    end

    def query_host(host)
      parse(get("host/#{host}"))
    rescue RestClient::ResourceNotFound
      nil
    rescue => e
      raise ProxyException.new(url, e, N_('Unable to query monitoring host object for %s') % host)
    end
  end
end
