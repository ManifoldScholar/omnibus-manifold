require_relative '../../util/clean_software.rb'
require_relative '../../util/read_version'

name "manifold"
maintainer "Zach Davis, Cast Iron Coding"
homepage "https://github.com/manifoldScholar/manifold"

license "GPL-3.0"

replace   "manifold"
conflict  "manifold"

# Defaults to C:/manifold on Windows
# and /opt/manifold on all other platforms
install_dir "#{default_root}/#{name}"

the_version = ReadVersion.('MANIFOLD_VERSION')
the_version = the_version[1..-1] if the_version.start_with? "v"
build_version the_version
build_iteration ReadVersion.build_iteration

# Creates required build directories
dependency "preparation"
# Healthcheck will fail without it because nginx software definition does not
# explicitly require it.
dependency "zlib"

# Manifold dependencies/components
dependency "nodejs-binary"
dependency "pandoc-binary"
dependency "chef-gem"
dependency "chef-zero"
dependency "openssl"
dependency "nginx"
dependency "runit"
dependency "redis"
dependency "postgresql"
dependency "imagemagick"
dependency "ruby"
dependency "bundler"
dependency "libxml2"
dependency "icu"
dependency "yarn"
dependency "logrotate"
dependency "elasticsearch"

# Manifold itself
dependency "manifold"
dependency "manifold-psql"
dependency "manifold-scripts"
dependency "manifold-ctl"
dependency "manifold-config-template"
dependency "manifold-cookbooks"

# Version manifest file
dependency "version-manifest"

exclude "**/.git"
exclude "**/bundler/git"

override :openssl, version: "1.1.1g"
override :nodejs, version: "12.18.3"
override :ruby, version: "2.6.6"
override :libtool, version: "2.4.2"
override :rubygems, version: "2.7.8"
override :bundler, version: "1.17.3"
override "omnibus-ctl", version: "v0.6.0"
override "rb-readline", version: "v0.5.5"
