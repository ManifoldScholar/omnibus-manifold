# The Manifold module in this file is used to parse /etc/manifold/manifold.rb.
#
# Warning to the reader:
# Because the Ruby DSL in /etc/manifold/manifold.rb does not accept hyphens in
# section names, this module translates names like 'manifold_api' to the
# correct 'manifold-api' in the `generate_hash` method. This module is the only
# place in the cookbook where we write 'manifold_api'.

require 'mixlib/config'
require 'chef/mash'
require 'chef/json_compat'
require 'chef/mixin/deep_merge'
require 'securerandom'
require 'uri'

require_relative 'manifold_api.rb'
require_relative 'logging.rb'
require_relative 'nginx.rb'
require_relative 'postgresql.rb'
require_relative 'redis.rb'

module Manifold
  extend Mixlib::Config

  bootstrap Mash.new
  manage_accounts Mash.new
  manage_storage_directories Mash.new
  user Mash.new
  postgresql Mash.new
  redis Mash.new
  manifold_api Mash.new
  unicorn Mash.new
  sidekiq Mash.new
  nginx Mash.new
  logging Mash.new
  remote_syslog Mash.new
  logrotate Mash.new
  web_server Mash.new
  node nil
  external_url nil

  # roles
  redis_sentinel_role Mash.new
  redis_master_role Mash.new
  redis_slave_role Mash.new

  ROLES ||= [
    'redis_sentinel',
    'redis_master',
    'redis_slave'
  ].freeze

  class << self
    def generate_secrets
      SecretsHelper.generate!
    end

    def generate_hash
      # NOTE: If you are adding a new service
      # and that service has logging, make sure you add the service to
      # the array in parse_udp_log_shipping.
      results = { "manifold" => {}, "roles" => {} }

      [
        "bootstrap",
        "manage_accounts",
        "manage_storage_directories",
        "user",
        "redis",
        "manifold_api",
        "puma",
        "cable",
        "sidekiq",
        "nginx",
        "logging",
        "remote_syslog",
        "logrotate",
        "postgresql",
        "web_server",
        "external_url",
      ].each do |key|
        rkey = key.gsub('_', '-')
        results['manifold'][rkey] = Manifold[key]
      end

      ROLES.each do |key|
        rkey = key.gsub('_', '-')
        results['roles'][rkey] = Manifold["#{key}_role"]
      end

      results
    end

    def sublibraries
      [
        ManifoldApi,
        Logging,
        Redis,
        Postgresql,
        # Parse nginx variables last because we want all external_url to be
        # parsed first
        Nginx
      ]
    end

    def generate_config(_node_name)
      generate_secrets

      sublibraries.each do |library|
        Chef::Log.warn "Parsing variables for #{library.name}"

        library.parse_variables
      end

      ManifoldApi.conditionally_disable_services

      # The last step is to convert underscores to hyphens in top-level keys
      generate_hash
    end
  end
end
