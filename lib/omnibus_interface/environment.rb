module OmnibusInterface
  class Environment
    attr_reader :root
    attr_reader :local_build
    attr_reader :packages_dir
    attr_reader :install_dir
    attr_reader :clean_dirs
    attr_reader :cookbook_dir
    attr_reader :vagrant

    def initialize(base_root = File.expand_path('../..', __dir__))
      @root         = Pathname.new base_root
      @local_build  = root.join 'local'
      @packages_dir = root.join 'pkg'
      @install_dir  = Pathname.new '/opt/manifold'
      @clean_dirs   = [install_dir].map do |path|
        local_build.join path
      end

      @cookbook_dir = install_dir.join 'embedded', 'cookbooks'

      @vagrant = OmnibusInterface::Vagrant.new
    end

    attr_lazy_reader :platform do
      if ubuntu16?
        :ubuntu16
      elsif ubuntu18?
        :ubuntu18
      elsif centos7?
        :centos7
      elsif macos?
        :macos
      end
    end

    def centos?
      ohai_platform == 'centos'
    end

    def centos7?
      centos? && ohai_platform_version.start_with?('7.')
    end

    def macos?
      ohai_platform == 'mac_os_x'
    end

    def ubuntu?
      ohai_platform == 'ubuntu'
    end

    def ubuntu16?
      ubuntu? && ohai_platform_version == '16.04'
    end

    def ubuntu18?
      ubuntu? && ohai_platform_version == '18.04'
    end

    # @!group Ohai methods

    attr_lazy_reader :ohai do
      build_ohai
    end

    attr_lazy_reader :ohai_platform do
      ohai[:platform]
    end

    attr_lazy_reader :ohai_platform_version do
      ohai[:platform_version]
    end

    # @!endgroup

    # @!group Executables / Scripts

    def is_old_tar(tar_path)
      "#{File.join('/vagrant/bin', 'is_old_tar')} #{tar_path}"
    end

    # @!endgroup

    private

    def build_ohai
      Ohai::System.new.tap do |system|
        system.all_plugins
      end
    end
  end
end
