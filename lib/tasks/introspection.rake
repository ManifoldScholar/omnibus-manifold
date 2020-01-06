namespace :introspection do
  desc 'List supported platforms'
  task :platforms, [:log_level] => :environment do |_t, args|
    puts JSON.generate(OmnibusInterface.project.platforms.map { |p| p.name })
  end
end