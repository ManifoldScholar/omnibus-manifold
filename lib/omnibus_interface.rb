module OmnibusInterface
  extend ActiveSupport::Autoload

  eager_autoload do
    autoload :Configurable
    autoload :Environment
    autoload :HasEnvironment
    autoload :Project
    autoload :Platform
    autoload :Vagrant
  end

  eager_load!

  mattr_accessor :env do
    OmnibusInterface::Environment.new File.expand_path('../', __dir__)
  end

  mattr_accessor :project_instance

  include OmnibusInterface::Configurable

  class << self
    delegate :vagrant, to: :env

    delegate :current_platform, to: :project

    def project
      project_instance.presence or raise "Must initialize the project"
    end
  end

  dsl do
    def project(name, &block)
      raise "Already initialized project" if object.project_instance.present?

      proj = OmnibusInterface::Project.new name

      proj.configure(&block)

      object.project_instance = proj
    end

    expose :project
  end
end
