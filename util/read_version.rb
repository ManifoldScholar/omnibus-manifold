require "omnibus/build_version"

module ReadVersion
  BUILD_VERSION = Omnibus::BuildVersion.new

  DETECTED_VERSION = [].tap do |ary|
    ary << ( "v" + BUILD_VERSION.version_tag )
    ary << BUILD_VERSION.prerelease_tag if BUILD_VERSION.prerelease_version?
  end.join(?-).freeze

  ROOT = File.expand_path('..', __dir__)

  class << self
    def build_iteration
      ::ReadVersion::BuildIteration.call.detect do |i|
        i.kind_of?(Integer) && i > 1
      end or 1
    end

    def call(path)
      found = File.join ROOT, path

      raise "Cannot find version file: #{path}" unless File.exist?(found)

      File.read(found).strip.tap do |contents|
        raise "Empty file" if contents.empty?
      end
    end
  end

  module BuildIteration
    class << self
      def call
        Enumerator.new do |y|
          y << ENV['OMNIBUS_BUILD_ITERATION'].to_i

          current_version = ReadVersion.call('MANIFOLD_VERSION')

          if DETECTED_VERSION == current_version
            y << Omnibus::BuildVersion.new.commits_since_tag
          end
        end
      end
    end
  end
end
