namespace :packages do
  desc 'List all of the latest packages'
  task :latest => :environment do
    OmnibusInterface.project.each do |platform|
      next unless platform.latest_package.present?

      puts "#{platform.name}: #{platform.latest_package}"
    end
  end

  desc 'List all existing packages'
  task :list => :environment do
    out = {}
    OmnibusInterface.project.each do |platform|
      out[platform.name] = platform.packages.map { |f| File.basename(f) }
    end
    puts JSON.generate(out)
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
