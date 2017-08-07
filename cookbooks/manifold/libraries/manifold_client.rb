require_relative 'nginx.rb'

module ManifoldClient
  class << self

    def public_path
      "#{Manifold['node']['package']['install-dir']}/embedded/src/client/dist/www"
    end

  end
end