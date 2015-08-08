require 'active_record'
require 'yaml'
require 'logger'

#task :default => :migrate

namespace :db do
  MIGRATIONS_DIR = "db/migrate"
  
  desc "Load database.yml"
  task :configuration do
    db = "db"
    env = ENV["ENV"] ? ENV["ENV"] : "development"
    p "environment : #{env}"
    @dbconfig = YAML::load(File.open("config/database.yml"))[db][env]
    #p @dbconfig
  end

  task :environment => :configuration do
    ActiveRecord::Base.establish_connection(@dbconfig)
    ActiveRecord::Base.logger = Logger.new("db/database.log")
  end
  
  desc "Migrate database by script in #{MIGRATIONS_DIR}"
  task :migrate => :environment do
    ActiveRecord::Migrator.migrate(MIGRATIONS_DIR, ENV["VERSION"] ? ENV["VERSION"].to_i : nil )
  end

  desc "Drops database"
  task :drop => :environment do
    db_name = @dbconfig["database"]
    p "drop #{db_name}"
    ActiveRecord::Base.connection.drop_database db_name rescue nil
  end

  desc "Roll back database schema to the previous version"
  task :rollback => :environment do
    ActiveRecord::Migrator.rollback(MIGRATIONS_DIR, ENV["STEP"] ? ENV["STEP"].to_i : 1)
  end
  
end
