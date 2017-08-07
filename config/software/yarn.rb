name "yarn"
default_version "0.28.4"

license "MIT"
license_file "COPYING"
skip_transitive_dependency_licensing true

version "0.28.4" do
  source md5: "60567689a1fd6bba33b2b6cdae6ef6ac"
end

source url: "https://github.com/yarnpkg/yarn/releases/download/v#{version}/yarn-v#{version}.tar.gz"

build do  
  copy "#{project_dir}/dist/bin/*", "#{install_dir}/embedded/bin/"
  copy "#{project_dir}/dist/lib/*", "#{install_dir}/embedded/lib/"
end