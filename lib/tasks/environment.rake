task :environment do
  require_relative '../omnibus_project'
  $project = OmnibusProject.new('manifold')
end
