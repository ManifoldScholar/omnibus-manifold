name "pandoc-binary"
default_version "2.2.2"

license "MIT"
license_file "LICENSE"
skip_transitive_dependency_licensing true

version "2.2.2" do
  source sha256: "115602dfa9200f177ddd75e140db24e1bd32d9ef440d03613b42f163186ade10"
end

source url: "https://github.com/jgm/pandoc/releases/download/#{version}/pandoc-#{version}-linux.tar.gz"
relative_path "pandoc-#{version}"

build do
  mkdir "#{install_dir}/bin/"

  copy "#{project_dir}/bin/pandoc", "#{install_dir}/bin"
  copy "#{project_dir}/bin/pandoc-citeproc", "#{install_dir}/bin"
end
