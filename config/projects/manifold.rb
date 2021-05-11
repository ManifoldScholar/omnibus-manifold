require_relative '../../util/clean_software.rb'
require_relative '../../util/read_version'

name "manifold"
maintainer "Zach Davis, Cast Iron Coding"
homepage "https://github.com/manifoldScholar/manifold"

license "GPL-3.0"

replace   "manifold"
conflict  "manifold"

# /opt/manifold on all installable platforms
install_dir "#{default_root}/#{name}"

the_version = ReadVersion.('MANIFOLD_VERSION')
the_version = the_version[1..-1] if the_version.start_with? "v"
build_version the_version
build_iteration ReadVersion.build_iteration

override :libtool, version: "2.4.6"

# Subsequent versions have a deprecation warning in Ubuntu 18 that will confuse our users.
# See https://github.com/rubygems/rubygems/issues/3068
override :rubygems, version: "3.2.17"

# For the Charlock Holmes Gem
dependency "icu"
# Centos has GCC 4.8, while recent icu needs 4.9 to compile.
if centos? && platform_version.start_with?("7")
  override :icu, version: "58.3"
else
  override :icu, version: "69.1"
end

# Needed for the rails console to work properly, since it's not included when ruby is installed.
dependency "rb-readline"

override "rb-readline", version: "v0.5.5"

# Creates required build directories
dependency "preparation"

# Healthcheck will fail without it because nginx software definition does not explicitly require it.
dependency "zlib"
override :zlib, version: "1.2.11"

dependency "openssl"
override :openssl, version: "1.1.1k"

dependency "ruby"
override :ruby, version: "2.7.3"

# We can go to v17 when Manifold is on Ruby v2.7 or higher
dependency "chef"
override "chef", version: "v16.13.23"

dependency "chef-zero"
override "chef-zero", version: "15.0.4"

dependency "nginx"
override "nginx", version: "1.18.0"

dependency "runit"
override "runit", version: "2.1.1"

dependency "redis"
override "redis", version: "5.0.7"

# For Latex ingestion
dependency "pandoc-binary"
override "pandoc-binary", version: "2.6"

dependency "bundler"
override :bundler, version: "2.2.17"

dependency "nodejs-binary"
override "nodejs-binary", version: "12.22.1"

dependency "yarn"
override :yarn, version: "1.22.5"

# For Nokogiri
dependency "libxml2"
override :libxml2, version: "2.9.10"

dependency "imagemagick"
override :imagemagick, version: "7.0.11-8"

dependency "postgresql"
override "postgresql", version: "13.2"

dependency "elasticsearch"
override :elasticsearch, version: "7.12.0"

dependency "logrotate"
override :logrotate, version: "3.18.0"

dependency "omnibus-ctl"
override "omnibus-ctl", version: "v0.6.0"

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
