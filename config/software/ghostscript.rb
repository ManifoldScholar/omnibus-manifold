name "ghostscript"

default_version '9.54.0'

license "AGPL-3.0"
license_file "LICENSE"
skip_transitive_dependency_licensing true

version "9.54.0" do
  source sha512: '93cfac3a754d4a7fa94112f3e04ba2ae633c40bb924734db72229096aac2f07c95877737f37f2bfef6be1b1d074af79e75cde3d589ea102def7f4654403e4804'
  source url: "https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs9540/ghostscript-9.54.0.tar.gz"
end

relative_path "ghostscript-#{version}"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  update_config_guess(target: "config")

  config_args = [
    "--prefix=#{install_dir}/embedded",
  ]

  command "./configure #{config_args.join(' ')}", env: env

  make "install", env: env
end