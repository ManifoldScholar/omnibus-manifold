name "libpng"

default_version '1.6.28'

license "libpng"
license_file "LICENSE"
skip_transitive_dependency_licensing true

dependency "config_guess"

version "1.6.28" do
  source md5: '425354f86c392318d31aedca71019372'
end

source url: "http://downloads.sourceforge.net/libpng/libpng-#{version}.tar.xz"

relative_path "libpng-#{version}"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  update_config_guess(target: "config")

  # patch source: "animated.patch", env: env

  config_args = [
      "--prefix=#{install_dir}/embedded",
  ]

  command "./configure #{config_args.join(' ')}", env: env

  make "-j #{workers}", env: env
  make "test", env: env
  make "install", env: env
end