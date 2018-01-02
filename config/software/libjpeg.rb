name "libjpeg"

default_version '8d'

# license "BSD-3-Clause"
# license_file "LICENSE"
# skip_transitive_dependency_licensing true

version '8d' do
  source sha256: "00029b1473f0f0ea72fbca3230e8cb25797fbb27e58ae2e46bb8bf5a806fe0b3"
end

source url: "http://www.ijg.org/files/jpegsrc.v#{version}.tar.gz"

relative_path "jpeg-#{version}"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  update_config_guess(target: "config")

  config_args = [
      "--prefix=#{install_dir}/embedded",
  ]

  command "./configure #{config_args.join(' ')}", env: env

  make "-j #{workers}", env: env
  # make "test", env: env
  make "install", env: env
end