require 'active_record'
require 'yaml'
require 'logger'

task :default => :migrate

namespace :db do
  desc "Load database.yml"
  task :configuration do
    @dbconfig = YAML::load(File.open("config/database.yml"))[ENV["ENV"]]
  end

  desc "Migrate database by script in db/migrate"
  task :migrate => :environment do
    ActiveRecord::Migrator.migrate('db/migrate', ENV["VERSION"] ? ENV["VERSION"].to_i : nil )
  end

  desc "Drops database"
  task :drop => :environment do
    ActiveRecord::Base.connection.drop_database(@dbconfig)
  end

  task :environment => :configuration do
    ActiveRecord::Base.establish_connection(@dbconfig)
    ActiveRecord::Base.logger = Logger.new("db/database.log")
  end
end
