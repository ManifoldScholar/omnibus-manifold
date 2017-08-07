desc 'Clean the local build directory'
task :clean => :environment do
  $project.clean!
end