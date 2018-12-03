require 'mixlib/shellout'
require_relative 'helper'
require 'shellwords'

class OmnibusHelper
  include ShellOutHelper

  attr_reader :node

  def initialize(node)
    @node = node
  end

  def should_notify?(service_name)
    File.symlink?("/opt/manifold/service/#{service_name}") && service_up?(service_name) && service_enabled?(service_name)
  end

  def not_listening?(service_name)
    File.exists?("/opt/manifold/service/#{service_name}/down") && service_down?(service_name)
  end

  def service_enabled?(service_name)
    node['manifold'][service_name]['enable']
  end

  def service_up?(service_name)
    success?("/opt/manifold/embedded/bin/sv status #{service_name}")
  end

  def service_down?(service_name)
    failure?("/opt/manifold/embedded/bin/sv status #{service_name}")
  end

  def user_exists?(username)
    success?("id -u #{username}")
  end

  def group_exists?(group)
    success?("getent group #{group}")
  end

  def redis_cli_command(*args)
    "/opt/manifold/embedded/bin/redis-cli #{redis_cli_args} #{escape_for_shell(args)}"
  end

  def redis_cli_args
    @redis_cli_args ||= escape_for_shell(build_redis_cli_args)
  end

  # Not usable until Redis 4.0+
  def redis_url
    @redis_url ||= build_redis_url
  end

  private

  def build_redis_cli_args
    [].tap do |args|
      redis = node['manifold']['redis']

      password = redis['password'].to_s

      args << '-h' << redis['bind']
      args << '-p' << redis['port']

      args << '-a' << password unless password.empty?
    end
  end

  def build_redis_url
    args = {}.tap do |h|
      redis = node['manifold']['redis']

      h[:scheme] = 'redis'

      password = redis['password'].to_s

      h[:userinfo] = ":#{password}" unless password.empty?

      h[:host] = redis['bind']
      h[:port] = redis['port']
      h[:path] = "/0"
    end

    URI::Generic.build(args).to_s
  end

  def escape_for_shell(args)
    Array(args).flatten.map do |arg|
      Shellwords.escape arg
    end.join(' ')
  end
end
