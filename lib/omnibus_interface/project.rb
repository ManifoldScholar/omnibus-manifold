module OmnibusInterface
  class Project
    include Cleanroom
    include Enumerable
    include FileUtils

    include OmnibusInterface::Configurable
    include OmnibusInterface::HasEnvironment

    attr_reader :name

    delegate :reconfigure_command, :sync_cookbooks_command, :sync_then_reconfigure_command, to: :current_platform!

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

    def current_platform!
      raise "Platform not able to be detected, cannot run" unless current_platform?

      current_platform
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

    def virtualized_deprecation_message(namespace:)
      tasks = virtualized_platforms.map do |platform|
        task_name = block_given? ? yield(platform) : platform.name

        "#{namespace}:#{task_name}"
      end

      [].tap do |m|
        m << '' << ''
        m << "Deprecated, run one of:"

        tasks.each do |task|
          m << "\tbin/rake #{task}"
        end

        m << '' << '' << ''
      end.join("\n")
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
