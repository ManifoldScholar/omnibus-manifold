name "libpng"

default_version '1.6.37'

license "libpng"
license_file "LICENSE"
skip_transitive_dependency_licensing true

dependency "config_guess"

version "1.6.37" do
  source sha512: '59e8c1059013497ae616a14c3abbe239322d3873c6ded0912403fc62fb260561768230b6ab997e2cccc3b868c09f539fd13635616b9fa0dd6279a3f63ec7e074'
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