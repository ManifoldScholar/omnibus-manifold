module OmnibusInterface
  class Platform
    include OmnibusInterface::Configurable
    include OmnibusInterface::HasEnvironment

    attr_reader :name

    attr_reader :project

    delegate :name, to: :project, prefix: true

    delegate :build_ssh_script_command, to: :vagrant

    def initialize(name:, project:)
      @name = name.to_s

      @project = project
    end

    # @!group Built Package methods

    def latest_package
      packages.max_by(&:ctime)
    end

    def latest_package!
      latest_package.presence or raise "No package found, did you build?"
    end

    def packages
      raise "Must have provided a #package_glob for #{name}" unless package_glob.present?

      env.packages_dir.children.select do |child|
        child.fnmatch package_glob
      end
    end

    # @!endgroup

    # @!group Configured Attributes

    attr_lazy_accessor :builder_vm do
      "#{name}-builder" if virtualized?
    end

    attr_lazy_accessor :install_vm do
      "#{name}-install" if virtualized?
    end

    attr_accessor :package_glob

    def virtualized=(new_value)
      @virtualized = new_value.present?
    end

    def virtualized?
      @virtualized.present?
    end

    # @!endgroup

    # @!group Remote commands

    # @return [void]
    def builder_is_running!
      vagrant.target_is_running! builder_vm
    end

    # @return [void]
    def install_is_running!
      vagrant.target_is_running! install_vm
    end

    # @param [String] box
    # @param [String] log_level
    # @return [String]
    def remote_build_command(log_level: 'info')
      raise "This cannot be run on non-virtualized platform" unless virtualized?

      build_ssh_script_command target: builder_vm do |s|
        s << "source ~/load-omnibus-toolchain.sh"
        s << "cd ~/omnibus-manifold"
        s << "bundle install -j 3 --binstubs"
        s << "bin/rake build:package[#{log_level}]"
      end
    end

    # @return [String]
    def remote_install_command
      package = latest_package!

      relative_package = package.relative_path_from root

      build_ssh_script_command target: install_vm do |s|
        s << "cd omnibus-manifold"
        s << install_package_command(relative_package)
        s << "sudo manifold-ctl reconfigure"
      end
    end

    # @!endgroup

    # @!group Shell Commands

    # @return [String]
    def install_command
      package = latest_package!

      install_package_command package.relative_path_from root
    end

    # @api private
    # @param [String, Pathname] package_path
    # @return [String]
    def install_package_command(package_path)
      case File.extname(package_path)
      when '.deb'
        %[sudo dpkg -i #{package_path}]
      when '.pkg'
        %[/usr/sbin/installer -pkg #{path_to_pkg} -target /]
      when '.rpm'
        %[sudo rpm -ivh #{package_path}]
      else
        raise "Unknown package extension: #{package_path}"
      end
    end

    # @!endgroup

    dsl do
      object! :platform

      delegate :project, to: :platform

      def builder_vm(name)
        platform.builder_vm = name
      end

      expose :builder_vm

      def install_vm(name)
        platform.install_vm = name
      end

      expose :install_vm

      # @param [String] glob
      # @return [void]
      def package_glob(glob)
        platform.package_glob = glob
      end

      expose :package_glob

      def virtualized!
        platform.virtualized = true
      end

      expose :virtualized!
    end
  end
end
