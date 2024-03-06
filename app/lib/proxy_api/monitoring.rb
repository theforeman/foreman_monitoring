# frozen_string_literal: true

module ProxyAPI
  class Monitoring < ProxyAPI::Resource
    def initialize(args)
      @url = "#{args[:url]}/monitoring"
      super args
    end

    def create_host_downtime(host, args = {})
      parse(post(args, "downtime/host/#{host}"))
    rescue StandardError => e
      raise ProxyException.new(url, e, N_('Unable to set downtime for %s') % host)
    end

    def remove_host_downtime(host, args = {})
      parse(delete("downtime/host/#{host}?#{args.to_query}"))
    rescue StandardError => e
      raise ProxyException.new(url, e, N_('Unable to remove downtime for %s') % host)
    end

    def create_host(host, attributes = {})
      parse(put({ :attributes => attributes }, "host/#{host}"))
    rescue StandardError => e
      raise ProxyException.new(url, e, N_('Unable to create monitoring host object for %s') % host)
    end

    def update_host(host, attributes = {})
      parse(post({ :attributes => attributes }, "host/#{host}"))
    rescue StandardError => e
      raise ProxyException.new(url, e, N_('Unable to update monitoring host object for %s') % host)
    end

    def delete_host(host)
      raise Foreman::Exception, 'Missing hostname.' if host.blank?

      parse(delete("host/#{host}"))
    rescue RestClient::ResourceNotFound
      true
    rescue StandardError => e
      raise ProxyException.new(url, e, N_('Unable to delete monitoring host object for %s') % host)
    end

    def query_host(host)
      parse(get("host/#{host}"))
    rescue RestClient::ResourceNotFound
      nil
    rescue StandardError => e
      raise ProxyException.new(url, e, N_('Unable to query monitoring host object for %{host}: %{message}') % { :host => host, :message => e.try(:response) || e.try(:message) })
    end
  end
end
