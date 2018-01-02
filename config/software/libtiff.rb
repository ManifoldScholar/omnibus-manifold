name "libtiff"

default_version '4.0.7'

dependency "config_guess"

license 'MIT'
license_file 'COPYRIGHT'

version '4.0.7' do
  source md5: '77ae928d2c6b7fb46a21c3a29325157b'
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