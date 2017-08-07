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
end
