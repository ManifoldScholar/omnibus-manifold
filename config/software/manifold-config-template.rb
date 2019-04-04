name "manifold-config-template"

license "Apache-2.0"
license_file File.expand_path("LICENSE", Omnibus::Config.project_root)
skip_transitive_dependency_licensing true

source :path => File.expand_path("files/manifold-config-template", Omnibus::Config.project_root)

build do
  command "mkdir -p #{install_dir}/etc"
  sync "./", "#{install_dir}/etc/"
end
