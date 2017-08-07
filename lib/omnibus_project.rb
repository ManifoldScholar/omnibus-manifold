require 'fileutils'
require 'pathname'

class OmnibusProject < Struct.new(:name)
  include FileUtils

  PROJECT_ROOT  = Pathname.new(File.expand_path('../', __dir__))
  LOCAL_BUILD   = PROJECT_ROOT.join('local')
  
  PACKAGES      = PROJECT_ROOT.join('pkg')

  INSTALL_DIR   = Pathname.new('/opt/manifold')

  CLEAN_DIRS    = [INSTALL_DIR] + %w[].map do |path|
                    LOCAL_BUILD.join(path)
                  end

  COOKBOOK_DIR  = INSTALL_DIR.join('embedded', 'cookbooks')

  alias_method :to_s, :name

  def build!(log_level: 'info')
    sh "bin/omnibus build #{name} --log-level #{log_level}"
  end

  def sync_cookbooks!
    sh "rsync -av cookbooks/ #{COOKBOOK_DIR}"
  end

  def clean!
    CLEAN_DIRS.each do |directory|
      warn "CLEANING #{directory}"
      rm_rf directory
    end
  end

  def debian_packages
    PACKAGES.children.select do |child|
      child.fnmatch('*.deb')
    end
  end

  def latest_debian_package
    debian_packages.max_by(&:ctime)
  end

  def osx_packages
    PACKAGES.children.select do |child|
      child.fnmatch('*.pkg')
    end
  end

  def latest_osx_package
    osx_packages.max_by(&:ctime)
  end

  def cookbook_dir
    COOKBOOK_DIR
  end

  def install_dir
    INSTALL_DIR
  end

  def root
    PROJECT_ROOT
  end
end
