name "yarn"
default_version "1.22.5"

license "MIT"
license_file "COPYING"
skip_transitive_dependency_licensing true

dependency "nodejs-binary"

version "1.22.5" do
  source sha512: "c33c040ed57eb05c04905b8996db31a34099f0c18dbf1818959c5592514abc99f1180592561ec5d3e760c084dbcf2dcdf3ebb4fe8918f082b6aa089cf10921bb"
end

source url: "https://github.com/yarnpkg/yarn/releases/download/v#{version}/yarn-v#{version}.tar.gz"

build do
  copy "#{project_dir}/yarn-v#{version}/bin/*", "#{install_dir}/embedded/bin/"
  copy "#{project_dir}/yarn-v#{version}/lib/*", "#{install_dir}/embedded/lib/"
end
