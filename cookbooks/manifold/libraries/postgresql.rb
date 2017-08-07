module Postgresql
  class << self
    def parse_variables
      parse_postgresql_settings
      parse_multi_db_host_addresses
    end

    def parse_postgresql_settings
      # If the user wants to run the internal Postgres service using an alternative
      # DB username, host or port, then those settings should also be applied to
      # manifold-api.
      [
        [%w{manifold_api db_username}, %w{postgresql sql_user}],
        [%w{manifold_api db_host},     %w{postgresql listen_address}],
        [%w{manifold_api db_port},     %w{postgresql port}],
      ].each do |left, right|
        unless Manifold[left.first][left.last].nil?
          # If the user explicitly sets a value for e.g.
          # manifold_api['db_port'] in manifold.rb then we should never override
          # that.
          next
        end

        better_value_from_manifold_rb    = Manifold[right.first][right.last]
        default_from_attributes       = Manifold['node']['manifold'][right.first.gsub('_', '-')][right.last]
        Manifold[left.first][left.last]  = better_value_from_manifold_rb || default_from_attributes
      end
    end

    def parse_multi_db_host_addresses
      # Postgres allow multiple listen addresses, comma-separated values
      # In case of multi listen_address, will use the first address from list
      db_host = Manifold['manifold_api']['db_host']

      return if db_host.nil?

      if db_host.include?(',')
        Manifold['manifold_api']['db_host'] = db_host.split(',')[0]
        warning = [
          "Received manifold_api['db_host'] value was: #{db_host.to_json}.",
          "First listen_address '#{Manifold['manifold_api']['db_host']}' will be used."
        ].join("\n  ")
        warn(warning)
      end
    end
  end
end
