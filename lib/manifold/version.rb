module Manifold
  class Version
    include Dux::Comparable.new(:semantic, sort_order: :desc)

    delegate :major, :minor, :patch, :pre, :version, to: :semantic

    def initialize(value)
      @value    = value
      @semantic = parse_value value
    end

    attr_reader :semantic
    attr_reader :value

    def value=(new_value)
      @semantic = parse_value new_value
      @value = new_value
    end

    def to_s
      "v#{@semantic}"
    end

    alias_method :to_str, :to_s

    private

    def parse_value(new_value)
      Semantic::Version.new new_value.sub(/\Av/, '')
    end
  end
end
