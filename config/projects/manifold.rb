#
# Copyright 2017 YOUR NAME
#
# All Rights Reserved.
#

name "manifold"
maintainer "CHANGE ME"
homepage "https://CHANGE-ME.com"

license "MIT"

replace   "vocat"
conflict  "vocat"

# Defaults to C:/manifold on Windows
# and /opt/manifold on all other platforms
install_dir "#{default_root}/#{name}"

build_version Omnibus::BuildVersion.semver
build_iteration 1

# Creates required build directories
dependency "preparation"

# manifold dependencies/components
dependency "chef-gem"
# dependency "chef-zero"
# dependency "openssl"
# dependency "nginx"
# dependency "runit"
# dependency "redis"
# dependency "postgresql"
# dependency "vocat-rails"
# dependency "vocat-cookbooks"
# dependency "vocat-ctl"
# dependency "vocat-psql"

# Version manifest file
dependency "version-manifest"

exclude "**/.git"
exclude "**/bundler/git"
