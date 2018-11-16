module ReadVersion
  ROOT = File.expand_path('..', __dir__)

  class << self
    def call(path)
      found = File.join ROOT, path

      raise "Cannot find version file: #{path}" unless File.exist?(found)

      File.read(found).strip.tap do |contents|
        raise "Empty file" if contents.empty?
      end
    end
  end
end
