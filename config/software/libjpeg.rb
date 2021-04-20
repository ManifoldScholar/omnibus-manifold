name "libjpeg"

default_version '9d'

version '9d' do
  source sha512: "6515a6f617fc9da7a3d7b4aecc7d78c4ee76159d36309050b7bf9f9672b4e29c2f34b1f4c3d7d65d7f6e2c104c49f53dd2e3b45eac22b1576d2cc54503faf333"
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