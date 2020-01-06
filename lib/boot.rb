$: << __dir__

require 'bundler/setup'
require 'fileutils'
require 'pathname'
require 'find'

require 'active_interaction'
require 'active_support/all'
require 'attr_lazy'
require 'cleanroom'
require 'dux'
require 'git'
require 'ohai'
require 'pry'
require 'ptools'

require 'dotenv/load'

Ohai.config[:log_level] = :error

require 'omnibus_interface'

OmnibusInterface.configure do
  project 'manifold' do
    platform 'macos' do
      package_glob 'macos/*.pkg'
    end

    platform 'ubuntu16' do
      package_glob 'ubuntu16/*.deb'

      virtualized!
    end

    platform 'ubuntu18' do
      package_glob 'ubuntu18/*.deb'

      uses_system_tar!

      virtualized!
    end

    platform 'centos7' do
      package_glob 'centos7/*.el7.x86_64.rpm'

      virtualized!
    end
  end
end
