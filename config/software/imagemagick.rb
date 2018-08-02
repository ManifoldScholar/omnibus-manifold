name "imagemagick"
default_version "7.0.6-9"

license "ImageMagick"
license_file "LICENSE"
skip_transitive_dependency_licensing true

dependency "config_guess"

dependency "bzip2"
dependency "libpng"
dependency "libjpeg"
dependency "liblzma"
dependency "libtiff"
dependency "libxml2"
dependency "zlib"

version '7.0.6-9' do
  source sha256: '74e25977aa0ea8f0fc5ca1e994a649d3660b82634f534725e46cea618a098377'
end

source url: "https://storage.googleapis.com/manifold-assets/omnibus/im7-src/ImageMagick-#{version}.tar.gz"

relative_path "ImageMagick-#{version}"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  update_config_guess(target: "config")

  #--disable-dependency-tracking
  # Build without C++ interface, graphviz, ghostscript, freetype, perl
  # Basically: nothing we won't need to resize images
  config_args = %W[
    --prefix=#{install_dir}/embedded
    --disable-silent-rules
    --enable-shared
    --enable-static
    --disable-opencl
    --disable-openmp
    --enable-hdri
    --without-magick-plus-plus
    --without-perl
    --without-x
    --without-pango
    --without-lcms
    --without-gvc
    --without-gslib
    --without-freetype
  ]

  config_args.unshift("--disable-osx-universal-binary") if mac_os_x?

  command "./configure #{config_args.join(' ')}", env: env

  make "-j #{workers}", env: env
  make "install", env: env
end
