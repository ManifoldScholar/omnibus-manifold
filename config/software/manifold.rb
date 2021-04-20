name "manifold"
default_version ReadVersion.('MANIFOLD_VERSION')
source path: File.expand_path('../../manifold-src', __dir__)

license :project_license
skip_transitive_dependency_licensing true

build do
  env = with_standard_compiler_flags(with_embedded_path)
  # Yarn will need node, so we'll add it to the path.
  env["PATH"] = "#{install_dir}/embedded/nodejs/bin:#{env["PATH"]}"

  bundle_without = %w[development test]
  api_dir = "#{project_dir}/api"
  client_dir = "#{project_dir}/client"

  # Install API gem dependencies
  bundle(
    "install --without #{bundle_without.join(' ')} --jobs #{workers} --retry 5 --path=vendor/bundle",
     env: env,
     cwd: api_dir
  )

  # Install Client node modules
  command "yarn install", cwd: client_dir, env: env

  # Delete all gem archives
  command "find #{install_dir} -name '*.gem' -type f -print -delete"

  # Delete all docs
  #  command "find #{install_dir}/embedded/lib/ruby/gems -name 'doc' -type d -print -exec rm -r {} +"

  # Because db/schema.rb can be modified after installation
  copy 'api/db/schema.rb', 'api/db/schema.rb.bundled'

  sync "#{project_dir}/", "#{install_dir}/embedded/src/", exclude: ["api/tmp", "api/public/system", "api/log", "config/keys"]

  erb dest: "#{install_dir}/bin/manifold-rake",
      source: 'bundle_exec_wrapper.sh.erb',
      mode:   0755,
      vars:   { command: 'rake "$@"', install_dir: install_dir }

  erb dest:   "#{install_dir}/bin/manifold-api",
      source: 'bundle_exec_wrapper.sh.erb',
      mode:   0755,
      vars:   { command: 'rails "$@"', install_dir: install_dir }

end
