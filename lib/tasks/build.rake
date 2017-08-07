namespace :build do

  task :package, [:log_level] => :environment do |_t, args|
    args.with_defaults(
      log_level: 'info'
    )
    $project.build!(log_level: args[:log_level])
  end

  task :in_vagrant, [:log_level] => :environment do |_t, args|
    args.with_defaults(
      log_level: 'info'
    )

    ssh_script = [
      "source ~/load-omnibus-toolchain.sh",
      "cd ~/omnibus-manifold",
      "bundle install -j 3 --binstubs",
      "bin/rake build:package[#{args[:log_level]}]"
    ].join(' && ')

    exec %[vagrant ssh -c #{Shellwords.shellescape(ssh_script)} builder]
  end
end

desc 'Build a package for the current platform'
task :build, :log_level do |_t, args|
  Rake::Task['build:package'].invoke(args[:log_level])
end
