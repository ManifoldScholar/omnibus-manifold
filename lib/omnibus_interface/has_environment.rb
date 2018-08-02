module OmnibusInterface
  module HasEnvironment
    extend ActiveSupport::Concern

    included do
      delegate :cookbook_dir, :install_dir, :root, :vagrant, to: :env
    end
      
    def env
      OmnibusInterface.env
    end
  end
end
