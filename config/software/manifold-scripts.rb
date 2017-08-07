name "manifold-scripts"

license "Apache-2.0"
license_file File.expand_path("LICENSE", Omnibus::Config.project_root)
source :path => File.expand_path("files/manifold-scripts", Omnibus::Config.project_root)

build do
  copy "*", "#{install_dir}/embedded/bin/"
end
