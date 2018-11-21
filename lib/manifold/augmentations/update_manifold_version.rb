module Manifold
  module Augmentations
    class UpdateManifoldVersion < ActiveInteraction::Base
      object :environment, class: 'Manifold::Environment'

      object :project, class: 'Manifold::Projects::Base'

      object :version, class: 'Manifold::Version'

      delegate :git, to: :project

      delegate :name, to: :project, prefix: true

      def execute
        update_manifold_version_file! if project.omnibus_manifold?

        puts "[#{project_name}] Adding annotated tag #{version}"

        git.add_tag version, annotate: true, message: "Release #{version}"

        puts "[#{project_name}] pushing to git"

        git.push('origin', 'master', tags: true)
      end

      private

      def update_manifold_version_file!
        puts "[#{project_name}] Updating MANIFOLD_VERSION file to read #{version}"

        project.manifold_version_file.write version.to_s

        git.add project.manifold_version_relative_path

        git.commit "[C] Update Manifold to #{version}"
      end
    end
  end
end
