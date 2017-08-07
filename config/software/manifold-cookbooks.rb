name 'manifold-cookbooks'

license :project_license

source path: File.expand_path('cookbooks', Omnibus::Config.project_root)

build do
  env = with_standard_compiler_flags(with_embedded_path)
  cookbooks_path = "#{install_dir}/embedded/cookbooks"
  command "mkdir -p #{cookbooks_path}", env: env
  sync "./", "#{cookbooks_path}"
end
