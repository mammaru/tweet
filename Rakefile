require 'active_record'
require 'yaml'
require 'logger'

task :default => :migrate

desc "Migrate database by script in db/migrate"
task :migrate => :environment do
  ActiveRecord::Migrator.migrate('db/migrate', ENV["VERSION"] ? ENV["VERSION"].to_i : nil )
end

task :environment do
  dbconfig = YAML::load(File.open('config/database.yml'))
  ActiveRecord::Base.establish_connection(dbconfig[ENV['ENV']])
  ActiveRecord::Base.logger = Logger.new('db/database.log')
end
