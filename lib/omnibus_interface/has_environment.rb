module OmnibusInterface
  module HasEnvironment
    extend ActiveSupport::Concern

    included do
      delegate :cookbook_dir, :install_dir, :root, :vagrant, to: :env
      delegate :platform, to: :env, prefix: :detected
    end
      
    def env
      OmnibusInterface.env
    end

    def detected_platform?
      detected_platform.present?
    end
  end
end
