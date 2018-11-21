module Manifold
  class Environment
    def initialize
      @env = ENV
    end

    def fetch(variable)
      @env.fetch variable do
        raise "'#{variable}' not found in ENV, make sure to configure .env"
      end
    end

    attr_lazy_reader :jenkins do
      Manifold::Jenkins.new env: self
    end

    attr_lazy_reader :projects do
      Manifold::Projects::Config.new env: self
    end
  end
end
