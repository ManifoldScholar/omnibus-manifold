namespace :install do
  desc 'Install the latest package'
  task :latest => :environment do
    package = $project.latest_osx_package
    path_to_pkg = package.relative_path_from($project.root)

    unless package && path_to_pkg
      fail 'No package found, did you build?'
    end

    cmd = "/usr/sbin/installer -pkg #{path_to_pkg} -target /"
    exec cmd

  end

  desc 'Install the latest debian package'
  task :in_vagrant => :environment do
    package = $project.latest_debian_package

    unless package
      fail 'No package found, did you build?'
    end

    ssh_script = [
        'cd omnibus-manifold',
        "sudo dpkg -i #{package.relative_path_from($project.root)}",
        "sudo manifold-ctl reconfigure"
    ].join(' && ')

    exec %[vagrant ssh -c #{Shellwords.shellescape(ssh_script)} install]
  end
end
