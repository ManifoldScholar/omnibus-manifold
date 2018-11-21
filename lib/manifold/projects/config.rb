module Manifold
  module Projects
    class Config
      include Enumerable
      include Manifold::UsesEnvironment

      def initialize(**options)
        super

        @projects = {}.with_indifferent_access
        @projects[:manifold_source] = Manifold::Projects::ManifoldSource.new manifold_source_path
        @projects[:omnibus_manifold] = Manifold::Projects::OmnibusManifold.new omnibus_manifold_path
      end

      def each
        return enum_for(__method__) unless block_given?

        @projects.each_value do |project|
          yield project, project.name
        end

        return self
      end

      def manifold_source
        @projects.fetch __method__
      end

      def omnibus_manifold
        @projects.fetch __method__
      end

      attr_lazy_reader :omnibus_manifold_path do
        Manifold::ROOT
      end

      attr_lazy_reader :manifold_source_path do
        File.expand_path env_fetch('MANIFOLD_SOURCE_PATH')
      end
    end
  end
end
