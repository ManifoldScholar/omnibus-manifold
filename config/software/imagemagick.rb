name "imagemagick"
default_version "7.0.11-8"

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
dependency "ghostscript"

version '7.0.11-8' do
  source sha512: '069cd3e8b46e7da75a860bb6f03a23a24acde75b63e0dc7a2e17333288bcb93c365a8ed55baa7b273fcb57e33d2acd859ef4755b63ed016f2b2240e69cb39893'
end

source url: "https://github.com/ImageMagick/ImageMagick/archive/refs/tags/#{version}.tar.gz"

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
    --without-freetype
  ]

  config_args.unshift("--disable-osx-universal-binary") if mac_os_x?

  command "./configure #{config_args.join(' ')}", env: env

  make "-j #{workers}", env: env
  make "install", env: env
end
