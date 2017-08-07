module Logging
  class << self
    def parse_variables
      parse_udp_log_shipping
    end

    def parse_udp_log_shipping
      logging = Manifold['logging']

      return unless logging['udp_log_shipping_host']

      Manifold['remote_syslog']['enable'] ||= true
      Manifold['remote_syslog']['destination_host'] ||= logging['udp_log_shipping_host']

      if logging['udp_log_shipping_port']
        Manifold['remote_syslog']['destination_port'] ||= logging['udp_log_shipping_port']
        Manifold['logging']['svlogd_udp'] ||= "#{logging['udp_log_shipping_host']}:#{logging['udp_log_shipping_port']}"
      else
        Manifold['logging']['svlogd_udp'] ||= logging['udp_log_shipping_host']
      end

      %w{
        redis
        nginx
        sidekiq
        unicorn
        postgresql
        remote-syslog
      }.each do |runit_sv|
        Manifold[runit_sv.gsub('-', '_')]['svlogd_prefix'] ||= "#{Manifold['node']['hostname']} #{runit_sv}: "
      end
    end
  end
end
