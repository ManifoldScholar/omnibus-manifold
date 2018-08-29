name "bzip2"
default_version "1.0.6"

license "BSD-2-Clause"
license_file "LICENSE"

dependency "zlib"
dependency "openssl"

version "1.0.6" do
  source url: "https://storage.googleapis.com/manifold-assets/omnibus/bzip2/bzip2_1.0.6.orig.tar.bz2",
         sha256: "d70a9ccd8bdf47e302d96c69fecd54925f45d9c7b966bb4ef5f56b770960afa7"
end

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
