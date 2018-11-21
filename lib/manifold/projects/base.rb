module Manifold
  module Projects
    # @abstract
    class Base
      def initialize(path, **options)
        @path = Pathname.new(path)
        @options = options.with_indifferent_access
      end

      def chdir
        Dir.chdir @path do
          yield @path if block_given?
        end
      end

      attr_lazy_reader :name do
        self.class.name.demodulize.underscore.inquiry
      end

      delegate :manifold_source?, :omnibus_manifold?, to: :name

      attr_reader :path
      attr_reader :options

      def current_version
        versions.first
      end

      attr_lazy_reader :git do
        Git.open @path.to_s
      end

      attr_lazy_reader :index do
        git.index
      end

      attr_lazy_reader :repository do
        git.repo
      end

      attr_lazy_reader :versions do
        get_versions
      end

      def reload
        @versions = get_versions
      end
        
      private

      def get_versions
        git.tags.map(&:name).grep(/\Av/).map { |version| Manifold::Version.new version }.sort
      end
    end
  end
end
