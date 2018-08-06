namespace :reconfigure do
  task :sync_cookbooks => :environment do
    exec OmnibusInterface.project.sync_cookbooks_command
  end

  task :reconfigure => :environment do
    exec OmnibusInterface.project.reconfigure_command
  end

  desc 'Sync cookbooks in install vm and run reconfigure'
  task :in_vagrant do
    fail OmnibusInterface.project.virtualized_deprecation_message(namespace: 'reconfigure')
  end

  OmnibusInterface.project.virtualized_platforms.each do |platform|
    desc "Sync cookbooks for #{platform.name} and then reconfigure Manifold"
    task platform.name => :environment do
      exec platform.remote_sync_then_reconfigure_command
    end
  end
end

desc 'Sync cookbook and run reconfigure'
task :reconfigure => %i[reconfigure:sync_cookbooks reconfigure:reconfigure] do |_t, args|
  # noop
end
