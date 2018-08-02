namespace :reconfigure do
  task :sync_cookbooks, [:log_level] => :environment do |_t, args|
    args.with_defaults(
      log_level: 'info'
    )

    OmnibusInterface.project.sync_cookbooks!
  end

  task :reconfigure, [:log_level] => :environment do |_t, args|
    args.with_defaults(
      log_level: 'info'
    )

    exec %[cd #{OmnibusInterface.project.install_dir} && manifold-ctl reconfigure]
  end

  desc 'Sync cookbooks in install vm and run reconfigure'
  task :in_vagrant, :log_level do |_t, args|
    ssh_script = [
      'cd omnibus-manifold',
      'sudo rsync -avzh /home/vagrant/omnibus-manifold/cookbooks/ /opt/manifold/embedded/cookbooks/',
      "sudo manifold-ctl reconfigure"
    ].join(' && ')
    exec %[vagrant ssh -c #{Shellwords.shellescape(ssh_script)} install]
  end
end

desc 'Sync cookbook and run reconfigure'
task :reconfigure, :log_level do |_t, args|
  Rake::Task['reconfigure:sync_cookbooks'].invoke(args[:log_level])
  exec "sudo rake reconfigure:reconfigure"
end
