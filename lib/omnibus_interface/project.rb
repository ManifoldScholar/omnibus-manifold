module OmnibusInterface
  class Project
    include Cleanroom
    include Enumerable
    include FileUtils

    include OmnibusInterface::Configurable
    include OmnibusInterface::HasEnvironment

    attr_reader :name

    def initialize(name)
      @name      = name
      @platforms = ThreadSafe::Cache.new
    end

    def each
      return enum_for(__method__) unless block_given?

      @platforms.each_value do |platform|
        yield platform
      end
    end

    def build_command(log_level: 'info')
      if current_platform?
        current_platform.local_build_command(log_level: log_level)
      else
        %[bin/omnibus build #{name} --log-level #{log_level}]
      end
    end

    def sync_cookbooks!
      sh "rsync -av cookbooks/ #{env.cookbook_dir}"
    end

    def clean!
      env.clean_dirs.each do |directory|
        warn "CLEANING #{directory}"
        rm_rf directory
      end
    end

    # @!group Platforms

    def [](platform_name)
      @platforms.fetch(platform_name.to_s)
    rescue KeyError
      raise "Unknown platform: #{platform_name.inspect}"
    end

    attr_lazy_reader :current_platform do
      self[env.platform] if detected_platform?
    end

    def current_platform?
      current_platform.present?
    end

    # @param [String] platform_name
    # @return [OmnibusInterface::Platform]
    def platform(platform_name)
      @platforms.compute_if_absent platform_name.to_s do
        OmnibusInterface::Platform.new name: platform_name, project: self
      end
    end

    def platforms
      @platforms.values
    end

    def virtualized_platforms
      platforms.select(&:virtualized?)
    end

    # @!endgroup

    alias_method :to_s, :name

    dsl do
      object! :project

      def platform(name, &block)
        project.platform(name).configure(&block)
      end

      expose :platform
    end
  end
end
