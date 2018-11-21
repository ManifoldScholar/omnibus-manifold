module Manifold
  module UsesEnvironment
    extend ActiveSupport::Concern

    included do
      delegate :fetch, to: :env, prefix: true
    end

    def initialize(env:, **other_options)
      @env = env
    end

    attr_reader :env
  end
end
