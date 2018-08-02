namespace :install do
  task :latest => :environment do
    fail "Deprecated, run one of the other install:* tasks"
  end

  task :in_vagrant => :environment do
    fail "Deprecated, run one of the other install:* tasks"
  end

  OmnibusInterface.project.each do |platform|
    if platform.virtualized?
      desc "Install the package for the #{platform.name} platform on a virtual machine"
      task platform.name => :environment do
        platform.install_is_running!

        exec platform.remote_install_command
      end
    else
      desc "Install the package for the #{platform.name} platform on this host"
      task platform.name => :environment do
        exec platform.install_command
      end
    end
  end
end
