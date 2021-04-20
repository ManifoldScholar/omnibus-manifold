name "libtiff"

default_version '4.2.0'

dependency "config_guess"

license 'MIT'
license_file 'COPYRIGHT'

version '4.2.0' do
  source sha512: 'd7d42e6e6dbda9604c638f28e6cfa4705191a4e8ea276d18031d50dbab0931ac91141e57a2cf294124487f1a2e6dfcb9be62431c1b69de5acf4d0e632f3322e5'
end

source url: "http://download.osgeo.org/libtiff/tiff-#{version}.tar.gz"

relative_path "tiff-#{version}"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  update_config_guess(target: "config")

  config_args = [
      "--prefix=#{install_dir}/embedded",
  ]

  command "./configure #{config_args.join(' ')}", env: env

  make "-j #{workers}", env: env
  make "check", env: env
  make "install", env: env
end