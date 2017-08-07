name "bzip2"
default_version "1.0.6"

license "BSD-2-Clause"
license_file "LICENSE"

dependency "zlib"
dependency "openssl"

version "1.0.6" do
  source md5: "00b516f4704d4a7cb50a1d97e6e8e15b"
end

source url: "http://www.bzip.org/#{version}/#{name}-#{version}.tar.gz"

relative_path "#{name}-#{version}"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  # Avoid warning where .rodata cannot be used when making a shared object
  env["CFLAGS"] << " -fPIC"

  # The list of arguments to pass to make
  args = "PREFIX='#{install_dir}/embedded' VERSION='#{version}'"

  patch source: "makefile_take_env_vars.patch", env: env
  patch source: "soname_install_dir.patch", env: env if mac_os_x?

  make "#{args}", env: env
  make "#{args} -f Makefile-libbz2_so", env: env
  make "#{args} install", env: env
end
