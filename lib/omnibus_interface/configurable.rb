module OmnibusInterface
  module Configurable
    extend ActiveSupport::Concern

    include ActiveSupport::Configurable

    included do
      config_accessor :dsl_klass

      config.dsl_klass = fetch_dsl_klass

      module_function :configure if instance_of? Module
    end

    # @return [self]
    def configure(&block)
      dsl_klass.new(self).evaluate(&block)

      return self
    end

    class_methods do
      def dsl(&block)
        dsl_klass.class_eval(&block)
      end

      # @api private
      # @return [Class]
      def fetch_dsl_klass
        return const_get(:DSL) if const_defined?(:DSL)

        Class.new(OmnibusInterface::Configurable::Configurator).tap do |klass|
          const_set :DSL, klass
        end
      end
    end

    # @abstract
    # @api private
    class Configurator
      include Cleanroom

      attr_reader :object

      def initialize(object)
        @object = object
      end

      class << self
        def object!(object_aliaz)
          alias_method object_aliaz, :object
        end
      end
    end
  end
end
