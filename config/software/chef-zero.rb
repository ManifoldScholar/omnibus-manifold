name "chef-zero"
default_version "4.8.0"

license "Apache-2.0"
license_file "https://raw.githubusercontent.com/chef/chef-zero/v#{version}/LICENSE"

dependency "ruby"
dependency "rubygems"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  gem "install chef-zero" \
      " --version '#{version}'" \
      " --bindir '#{install_dir}/embedded/bin'" \
      " --no-ri --no-rdoc", env: env
end
