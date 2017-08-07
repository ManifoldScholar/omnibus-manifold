require_relative 'nginx.rb'

module ManifoldApi
  class << self
    def parse_variables
      parse_external_url
      parse_directories
    end

    def parse_directories
      parse_shared_dir
    end

    def parse_external_url
      return unless Manifold['external_url']

      uri = URI(Manifold['external_url'].to_s)
      unless uri.host
        raise "Manifold external URL must include a schema and FQDN, e.g. http://manifold.example.com/"
      end

      Manifold['manifold_api']['manifold_host'] = uri.host
      Manifold['manifold_api']['manifold_email_from'] ||= "manifold@#{uri.host}"

      case uri.scheme
      when "http"
        Manifold['manifold_api']['manifold_https'] = false
        Nginx.parse_proxy_headers('nginx', false)
      when "https"
        Manifold['manifold_api']['manifold_https']   = true
        Manifold['nginx']['ssl_certificate']     ||= "/etc/manifold/ssl/#{uri.host}.crt"
        Manifold['nginx']['ssl_certificate_key'] ||= "/etc/manifold/ssl/#{uri.host}.key"
        Nginx.parse_proxy_headers('nginx', true)
      else
        raise "Unsupported external URL scheme: #{uri.scheme}"
      end

      unless ["", "/"].include?(uri.path)
        relative_url = uri.path.chomp("/")

        Manifold['manifold_api']['manifold_relative_url'] ||= relative_url
        Manifold['unicorn']['relative_url'] ||= relative_url
      end

      Manifold['manifold_api']['manifold_port'] = uri.port
    end

    def parse_shared_dir
      a = Manifold['manifold_api']['shared_path']
      # TODO: Something isn't right here. The second case is used by
      # manifold-ctl show-config, but Manifold['node'] appears to be empty.
      b = Manifold['node'] ? Manifold['node']['manifold']['manifold-api']['shared_path'] : nil
      a ||= b
    end

    def conditionally_disable_services
      disable_services_roles if any_role_defined?

      conditionally_disable_manifold_api_services
    end

    def system_path
      "#{Manifold['node']['package']['install-dir']}/embedded/src/api/public"
    end

    private

    def any_role_defined?
      Manifold::ROLES.any? { |role| Manifold["#{role}_role"]['enable'] }
    end

    def disable_services_roles
      if Manifold['redis_master_role']['enable']
        disable_non_redis_services

        Manifold['redis']['enable'] = true
      end

      if Manifold['redis_slave_role']['enable']
        disable_non_redis_services

        Manifold['redis']['enable'] = true
      end

      if Manifold['redis_master_role']['enable'] && Manifold['redis_slave_role']['enable']
        fail 'Cannot define both redis_master_role and redis_slave_role in the same machine.'
      elsif Manifold['redis_master_role']['enable'] || Manifold['redis_slave_role']['enable']
        disable_non_redis_services
      else
        Manifold['redis']['enable'] = false
      end
    end

    def conditionally_disable_manifold_api_services
      if Manifold['manifold_api']['enable'] == false
        Manifold['unicorn']['enable'] = false
        Manifold['sidekiq']['enable'] = false
      end
    end

    def disable_non_redis_services
      Manifold['manifold_api']['enable']  = false
      Manifold['bootstrap']['enable']    = false
      Manifold['nginx']['enable']        = false
      Manifold['postgresql']['enable']   = false
    end
  end
end
