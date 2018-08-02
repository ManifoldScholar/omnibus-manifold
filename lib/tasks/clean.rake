desc 'Clean the local build directory'
task :clean => :environment do
  OmnibusInterface.project.clean!
end
