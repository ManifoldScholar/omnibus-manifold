$: << __dir__

require 'bundler/setup'
require 'fileutils'
require 'pathname'

require 'active_support/all'
require 'attr_lazy'
require 'cleanroom'
require 'ohai'
require 'pry'
require 'ptools'

Ohai.config[:log_level] = :error

require 'omnibus_interface'

OmnibusInterface.configure do
  project 'manifold' do
    platform 'macos' do
      package_glob '*.pkg'
    end

    platform 'ubuntu16' do
      package_glob '*.deb'

      virtualized!
    end

    platform 'centos7' do
      package_glob '*.el7.x86_64.rpm'

      virtualized!
    end
  end
end
