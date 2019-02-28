name "yarn"
default_version "1.13.0"

license "MIT"
license_file "COPYING"
skip_transitive_dependency_licensing true

dependency "nodejs-binary"

version "1.13.0" do
  source md5: "a466d851585045cf5a16f6c5bd7c3bad"
end

source url: "https://github.com/yarnpkg/yarn/releases/download/v#{version}/yarn-v#{version}.tar.gz"

build do
  copy "#{project_dir}/yarn-v#{version}/bin/*", "#{install_dir}/embedded/bin/"
  copy "#{project_dir}/yarn-v#{version}/lib/*", "#{install_dir}/embedded/lib/"
end
