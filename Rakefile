require 'active_record'
require 'yaml'
require 'logger'

#task :default => :migrate

namespace :db do
  
  task :environment do
    MIGRATIONS_DIR = "db/migrate"
    DB = "db"
    DEV_ENV = ENV["ENV"] || "development"
  end
  
  task :configuration => :environment do
    puts "Environment : " + DEV_ENV 
    @dbconfig = YAML::load(File.open("config/database.yml"))[DB][DEV_ENV]
    #p @dbconfig
  end

  task :configure_connection => :configuration do
    ActiveRecord::Base.establish_connection(@dbconfig)
    ActiveRecord::Base.logger = Logger.new("db/database.log")
  end
  
  desc "Migrate database by script in db/migrate"
  task :migrate => :configure_connection do
    ActiveRecord::Migrator.migrate(MIGRATIONS_DIR, ENV["VERSION"] ? ENV["VERSION"].to_i : nil )
  end

  desc "Roll back database schema to the previous version"
  task :rollback => :configure_connection do
    ActiveRecord::Migrator.rollback(MIGRATIONS_DIR, ENV["STEP"] ? ENV["STEP"].to_i : 1)
  end
  
  desc "Drop database"
  task :drop => :configure_connection do
    db_name = @dbconfig["database"]
    puts "Drop #{db_name}"
    ActiveRecord::Base.connection.drop_database db_name
  end

  desc "Retrieves the current schema version number"
  task :version => :configure_connection do
    puts "Current version: #{ActiveRecord::Migrator.current_version}"
  end
  
end
