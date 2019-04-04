namespace :install do
  task :latest => :environment do
    fail OmnibusInterface.project.virtualized_deprecation_message(namespace: :install)
  end

  task :in_vagrant => :environment do
    fail OmnibusInterface.project.virtualized_deprecation_message(namespace: :install)
  end

  OmnibusInterface.project.each do |platform|
    if platform.virtualized?
      desc "Install the package for the #{platform.name} platform on a virtual machine"
      task platform.name, [:pkg] => :environment do |task, args|

        platform.install_is_running!
        platform.package_glob = "*/#{platform.name}/#{args[:pkg]}" if args[:pkg]
        
        exec platform.remote_install_command
      end
    else
      desc "Install the package for the #{platform.name} platform on this host"
      task platform.name, [:pkg] => :environment do |task, args|
        platform.package_glob = "*/#{platform.name}/#{args[:pkg]}" if args[:pkg]
        exec platform.install_command
      end
    end
  end
end
