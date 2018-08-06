namespace :packages do
  desc 'List all of the latest packages'
  task :latest => :environment do
    OmnibusInterface.project.each do |platform|
      next unless platform.latest_package.present?

      puts "#{platform.name}: #{platform.latest_package}"
    end
  end

  OmnibusInterface.project.each do |platform|
    desc "Print the path to the latest #{platform.name} package"
    task platform.name => :environment do
      if platform.latest_package.present?
        puts platform.latest_package
      else
        exit 1
      end
    end
  end
end
