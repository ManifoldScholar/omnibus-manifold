module Manifold
  extend ActiveSupport::Autoload

  ROOT = Pathname.new(File.expand_path('..', __dir__))

  eager_autoload do
    autoload :Application
    autoload :Environment
    autoload :Jenkins
    autoload :UsesEnvironment
    autoload :Version
  end

  module Augmentations
    extend ActiveSupport::Autoload

    eager_autoload do
      autoload :MakeRelease
      autoload :UpdateManifoldVersion
    end
  end

  module Projects
    extend ActiveSupport::Autoload

    eager_autoload do
      autoload :Base
      autoload :Config
      autoload :ManifoldSource
      autoload :OmnibusManifold
    end
  end

  eager_load!

  Augmentations.eager_load!
  Projects.eager_load!
end
