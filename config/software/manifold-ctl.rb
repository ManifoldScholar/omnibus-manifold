require 'erb'

name "manifold-ctl"

license :project_license
skip_transitive_dependency_licensing true

dependency "omnibus-ctl"
dependency "runit"

source :path => File.expand_path("files/manifold-ctl-commands", Omnibus::Config.project_root)

build do
  block do
    erb source: 'manifold-ctl.sh.erb',
        dest: "#{install_dir}/bin/manifold-ctl",
        mode: 0755,
        vars: { install_dir: project.install_dir }
  end

  # Additional omnibus-ctl commands
  sync "./", "#{install_dir}/embedded/service/omnibus-ctl/"
end
