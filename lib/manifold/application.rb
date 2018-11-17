module Manifold
  class Application
    include Commander::Methods

    def initialize
      @environment = Manifold::Environment.new
    end

    def run
      program :name, 'Manifold'
      program :version, '1.0.0'
      program :description, 'Simplifies manifold release structure'

      command :release do |c|
        c.syntax = "manifold release VERSION"
        c.description = "Tags and creates a new release"

        c.option '--jenkins', 'Trigger a jenkins build without prompting'

        c.action do |args, options|
          Manifold::Augmentations::MakeRelease.run! environment: @environment, args: args, options: options
        end
      end

      run!
    rescue Interrupt => e
      warn "\n\nInterrupt caught, exiting"

      exit 1
    end
  end
end
