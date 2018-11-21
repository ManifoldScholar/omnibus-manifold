module Manifold
  module Augmentations
    class MakeRelease < ActiveInteraction::Base
      object :environment, class: 'Manifold::Environment'

      array :args, default: proc { [] } do
        string
      end

      object :options, class: 'Commander::Command::Options'

      delegate :jenkins, :projects, to: :environment

      delegate :build!, to: :jenkins, prefix: true

      delegate :manifold_source, :omnibus_manifold, to: :projects

      def execute
        @version = wait_for_version

        puts "Going to release #{version}, previously tagged versions:\n"

        projects.each do |project|
          puts "\t* #{project.name}: #{project.current_version}"
        end

        print "\n"

        correct = agree "Does this look correct? "

        unless correct
          errors.add :base, "Okay, bailing early"

          return
        end

        projects.each do |project|
          compose Manifold::Augmentations::UpdateManifoldVersion, project: project, environment: environment, version: version
        end

        build_with_jenkins = options.jenkins || agree("Build on Jenkins? ")

        if build_with_jenkins
          result = jenkins_build! version

          if result != "201"
            errors.add :base, "Got unexpected result from jenkins build: #{result} (expected 201). Check jenkins"

            return
          end
        else
          warn "Skipping jenkins build"
        end

      end

      attr_reader :version

      private

      def wait_for_version
        provided = args.first

        loop do
          version = try_parsing provided

          break version if version.present?

          provided = ask("Specify the version: ")
        end
      end

      def try_parsing(provided_version)
        return nil unless provided_version.present?

        Manifold::Version.new provided_version
      rescue ArgumentError => e
        warn "Could not parse '#{provided_version}': #{e.message}"

        return nil
      end
    end
  end
end
