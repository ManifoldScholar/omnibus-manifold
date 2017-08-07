namespace :reconfigure do

  task :sync_cookbooks, [:log_level] => :environment do |_t, args|
    args.with_defaults(
      log_level: 'info'
    )    
    $project.sync_cookbooks!
  end

  task :reconfigure, [:log_level] => :environment do |_t, args|
    args.with_defaults(
      log_level: 'info'
    )
    exec %[cd #{$project.install_dir} && manifold-ctl reconfigure]
  end

end

desc 'Sync cookbook and run reconfigure'
task :reconfigure, :log_level do |_t, args|
  Rake::Task['reconfigure:sync_cookbooks'].invoke(args[:log_level])
  exec "sudo rake reconfigure:reconfigure"
  # Rake::Task['reconfigure:reconfigure'].invoke(args[:log_level])
end
