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
  end
end
