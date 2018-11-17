module Manifold
  module Projects
    class OmnibusManifold < Base
      attr_lazy_reader :manifold_version_file do
        path.join 'MANIFOLD_VERSION'
      end

      def manifold_version_relative_path
        manifold_version_file.relative_path_from(path).to_s
      end
    end
  end
end
