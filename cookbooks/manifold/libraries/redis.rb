require_relative 'redis_uri'

module Redis
  class << self
    def parse_variables
      parse_redis_settings
    end

    def parse_redis_settings
      if is_redis_tcp?
        # The user wants Redis to listen via TCP instead of unix socket.
        Manifold['redis']['unixsocket'] = false
      end

      if redis_managed? && Manifold['redis_master_role']['enable']
        Manifold['redis']['master_password'] ||= Manifold['redis']['password']
      end

      if is_manifold_api_redis_tcp?
        # The user wants to connect to a Redis instance via TCP.
        # It can be either a non-bundled instance or a Sentinel based one.
        # Overriding redis_socket to false signals that manifold-api
        # should connect to Redis via TCP instead of a Unix domain socket.
        Manifold['manifold_api']['redis_port'] ||= 6379
        Manifold['manifold_api']['redis_socket'] = false
      end
    end

    private
    def parse_redis_daemon!
      return unless redis_managed?

      redis_bind = Manifold['redis']['bind'] || node['manifold']['redis']['bind']

      Manifold['manifold_api']['redis_host']      ||= redis_bind
      Manifold['manifold_api']['redis_port']      ||= Manifold['redis']['port']
      Manifold['manifold_api']['redis_password']  ||= Manifold['redis']['master_password']

      if Manifold['manifold_api']['redis_host'] != redis_bind
        Chef::Log.warn "manifold-api 'redis_host' is different than 'bind' value defined for managed redis instance. Are you sure you are pointing to the same redis instance?"
      end

      if Manifold['manifold_api']['redis_port'] != Manifold['redis']['port']
        Chef::Log.warn "manifold-api 'redis_port' is different than 'port' value defined for managed redis instance. Are you sure you are pointing to the same redis instance?"
      end

      if Manifold['manifold_api']['redis_password'] != Manifold['redis']['master_password']
        Chef::Log.warn "manifold-api 'redis_password' is different than 'master_password' value defined for managed redis instance. Are you sure you are pointing to the same redis instance?"
      end
    end

    def node
      Manifold[:node]
    end

    def is_redis_tcp?
      Manifold['redis']['port'] && Manifold['redis']['port'] > 0
    end

    def is_redis_slave?
      Manifold['redis']['master'] == false
    end

    def is_manifold_api_redis_tcp?
      Manifold['manifold_api']['redis_host']
    end

    def redis_managed?
      Manifold['redis']['enable'].nil? ? node['manifold']['redis']['enable'] : Manifold['redis']['enable']
    end
  end
end
