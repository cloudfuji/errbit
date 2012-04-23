require 'fileutils'

namespace :cloudfuji do
  
  desc "Copys of example config files"
  task :copy_configs do
    configs = {
      'mongoid.cloudfuji.yml' => 'mongoid.yml'
    }
    
    puts "Copying example config files..."
    configs.each do |old, new|
      if File.exists?("config/#{new}")
        puts "-- Skipping config/#{new}: already exists"
      else
        puts "-- Copying config/#{old} to config/#{new}"
        FileUtils.cp "config/#{old}", "config/#{new}"
      end
    end
  end
  
  desc "Run the initial setup for a Busido app. Copies config files and seeds db."
  task :install do
    Rake::Task['cloudfuji:copy_configs'].execute
    puts "\n"
    Rake::Task['db:seed'].invoke
    puts "\n"
    Rake::Task['db:mongoid:create_indexes'].invoke
  end
end
