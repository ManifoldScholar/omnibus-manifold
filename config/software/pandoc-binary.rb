name "pandoc-binary"
default_version "2.6"

license "MIT"
license_file "LICENSE"
skip_transitive_dependency_licensing true

version "2.6" do
  source sha256: "4f40bddeb0b0fa50a89c0301e9342c52439d4d8685f0631cafd040dcc2c97ab3"
end

source url: "https://github.com/jgm/pandoc/releases/download/#{version}/pandoc-#{version}-linux.tar.gz"
relative_path "pandoc-#{version}"

build do
  mkdir "#{install_dir}/bin/"

  copy "#{project_dir}/bin/pandoc", "#{install_dir}/bin"
  copy "#{project_dir}/bin/pandoc-citeproc", "#{install_dir}/bin"
end
