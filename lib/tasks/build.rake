namespace :build do
  desc 'Build the package for the current platform'
  task :package, [:log_level] => :environment do |_t, args|
    args.with_defaults(
      log_level: 'info'
    )

    exec OmnibusInterface.project.build_command(log_level: args[:log_level])
  end

  OmnibusInterface.project.virtualized_platforms.each do |platform|
    desc "Build the package for #{platform} in a vagrant box"
    task platform.name.to_sym, [:log_level] => :environment do |_t, args|
      args.with_defaults(
        log_level: 'info'
      )

      platform.builder_is_running!

      exec platform.remote_build_command log_level: args[:log_level]
    end
  end

  task :in_vagrant, [:log_level] => :environment do |_t, args|
    fail "\n\n\nDeprecated, run build:ubuntu16 or build:centos7\n\n\n"
  end
end

desc 'Build a package for the current platform'
task :build, :log_level do |_t, args|
  Rake::Task['build:package'].invoke(args[:log_level])
end
