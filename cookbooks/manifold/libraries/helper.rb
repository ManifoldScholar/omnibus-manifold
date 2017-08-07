require 'mixlib/shellout'
require 'uri'
require 'digest'

module ShellOutHelper
  def do_shell_out(cmd, user = nil, cwd = nil)
    o = Mixlib::ShellOut.new(cmd, user: user, cwd: cwd)
    o.run_command
    o
  rescue Errno::EACCES
    Chef::Log.info("Cannot execute #{cmd}.")
    o
  rescue Errno::ENOENT
    Chef::Log.info("#{cmd} does not exist.")
    o
  end

  def success?(cmd)
    o = do_shell_out(cmd)
    o.exitstatus == 0
  end

  def failure?(cmd)
    o = do_shell_out(cmd)
    o.exitstatus != 0
  end
end

class PgHelper
  include ShellOutHelper

  attr_reader :node

  def initialize(node)
    @node = node
  end

  def is_running?
    OmnibusHelper.new(node).service_up?("postgresql")
  end

  def database_exists?(db_name)
    psql_cmd(["-d 'template1'",
              "-c 'select datname from pg_database' -A",
              "| grep -x #{db_name}"])
  end

  def user_exists?(db_user)
    psql_cmd(["-d 'template1'",
              "-c 'select usename from pg_user' -A",
              "|grep -x #{db_user}"])
  end

  def is_slave?
    psql_cmd(["-d 'template1'",
              "-c 'select pg_is_in_recovery()' -A",
              "|grep -x t"])
  end

  def psql_cmd(cmd_list)
    cmd = ["/opt/manifold/bin/manifold-psql", cmd_list.join(" ")].join(" ")
    success?(cmd)
  end

  def version
    VersionHelper.version('/opt/manifold/embedded/bin/psql --version').split.last
  end

  def database_version
    version_file = "#{@node['manifold']['postgresql']['data_dir']}/PG_VERSION"

    if File.exist?(version_file)
      File.read(version_file).chomp
    else
      nil
    end
  end
end

module ConfigHelper
  CONFIG_DIR ||= Pathname.new('/etc/manifold')

  module_function
  # @return [Pathname]
  def config_file(*parts)
    CONFIG_DIR.join(*parts)
  end

  def directory_exists?
    CONFIG_DIR.exist?
  end
end

module SecretsHelper
  SECRETS_FILE  ||= ConfigHelper.config_file('manifold-secrets.json')

  MANIFOLD_API_SECRETS ||= %w[
    secret_key_base
    db_key_base
    otp_key_base
    smtp_user_name
    smtp_password
    aws_access_key_id
    aws_secret_access_key
  ]

  MANAGED_SECRETS ||= %w[
  ]

  HEX_SECRETS ||= %w[
    db_key_base
    secret_key_base
    otp_key_base
  ]

  class << self
    # @see [#read_manifold_secrets!]
    # @see [#fill_in_defaults!]
    # @see [#write_to_manifold_secrets!]
    def generate!
      read_manifold_secrets!

      fill_in_defaults!

      write_to_manifold_secrets!
    end

    # Load secrets from {SECRETS_FILE}.
    #
    # @note Specifying a secret in /etc/manifold/manifold.rb will take
    #   precedence over `manifold-secrets.json`
    # @return [void]
    def read_manifold_secrets!
      existing_secrets = {}

      if File.exists?(SECRETS_FILE)
        existing_secrets = Chef::JSONCompat.from_json(File.read(SECRETS_FILE))
      end


      existing_secrets.each do |k, v|
        if Manifold[k]
          v.each do |pk, p|
            Manifold[k][pk] ||= p
          end
        else
          warn("Ignoring section #{k} in #{SECRETS_FILE}, does not exist in manifold.rb")
        end
      end
    end

    # Set default hex-generated secrets.
    #
    # @note Guards against creating secrets on non-bootstrap node
    # @return [void]
    def fill_in_defaults!
      HEX_SECRETS.each do |secret_name|
        Manifold['manifold_api'][secret_name] ||= generate_hex(64)
      end
    end

    # Pull secret information out of `Manifold['manifold_api']`
    # and write to {SECRETS_FILE}.
    #
    # @return [void]
    def write_to_manifold_secrets!
      secret_tokens = {}

      secret_tokens['manifold_api'] = MANIFOLD_API_SECRETS.each_with_object({}) do |secret_name, section|
        section[secret_name] = Manifold['manifold_api'][secret_name]
      end

      if ConfigHelper.directory_exists?
        File.open(SECRETS_FILE, 'w', 0600) do |f|
          f.puts(Chef::JSONCompat.to_json_pretty(secret_tokens))
          f.chmod(0600)
        end
      end
    end

    private
    def generate_hex(chars)
      SecureRandom.hex(chars)
    end
  end
end

module SingleQuoteHelper
  def single_quote(string)
   "'#{string}'" unless string.nil?
  end
end

class RedhatHelper
  def self.system_is_rhel7?
    platform_family == "rhel" && platform_version =~ /7\./
  end

  def self.platform_family
    case platform
    when /oracle/, /centos/, /redhat/, /scientific/, /enterpriseenterprise/, /amazon/, /xenserver/, /cloudlinux/, /ibm_powerkvm/, /parallels/
      "rhel"
    else
      "not redhat"
    end
  end

  def self.platform
    contents = read_release_file
    get_redhatish_platform(contents)
  end

  def self.platform_version
    contents = read_release_file
    get_redhatish_version(contents)
  end

  def self.read_release_file
    if File.exists?("/etc/redhat-release")
      contents = File.read("/etc/redhat-release").chomp
    else
      "not redhat"
    end
  end

  # Taken from Ohai
  # https://github.com/chef/ohai/blob/31f6415c853f3070b0399ac2eb09094eb81939d2/lib/ohai/plugins/linux/platform.rb#L23
  def self.get_redhatish_platform(contents)
    contents[/^Red Hat/i] ? "redhat" : contents[/(\w+)/i, 1].downcase
  end

  # Taken from Ohai
  # https://github.com/chef/ohai/blob/31f6415c853f3070b0399ac2eb09094eb81939d2/lib/ohai/plugins/linux/platform.rb#L27
  def self.get_redhatish_version(contents)
    contents[/Rawhide/i] ? contents[/((\d+) \(Rawhide\))/i, 1].downcase : contents[/release ([\d\.]+)/, 1]
  end
end

class VersionHelper
  extend ShellOutHelper

  def self.version(cmd)
    result = do_shell_out(cmd)

    if result.exitstatus == 0
      result.stdout
    else
      nil
    end
  end
end
