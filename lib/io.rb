# coding: utf-8
require 'time'
#require "active_support/core_ext/hash/conversions"
require 'fileutils'
require 'rexml/document'
#require 'json'
require 'sqlite3'
require 'active_record'
require 'yaml'
require 'logger'

# loading files in lib/
$LOAD_PATH << File.expand_path("..", __FILE__) unless $LOAD_PATH.include? File.expand_path("..", __FILE__)
require 'models.rb'


class DataBase
  include Singleton

  def initialize
    @db = "db"
    @env = ENV["ENV"] ? ENV["ENV"] : "development"
    @dbconfig = YAML::load(File.open("#{ENV["ROOT"]}/config/database.yml"))[@db][@env]
    if File.exists?("#{ENV["ROOT"]}/#{@dbconfig["database"]}") then
      # retrieve connection to database
      ActiveRecord::Base.establish_connection(@dbconfig)
    else
      # create database and migrate
      p "create database and execute migration."
      migrt_dir = ENV["ROOT"] + "/db/migrate"
      #@dbconfig = YAML::load(File.open("config/database.yml"))[@db][@env]
      ActiveRecord::Base.establish_connection(@dbconfig)
      ActiveRecord::Base.logger = Logger.new("#{ENV["ROOT"]}/db/database.log")
      ActiveRecord::Migrator.migrate(migrt_dir)
    end
  end

  def tweets
    Tweet.all
  end

  def users
    User.all
  end

  def autonomies
    Autonomy.all
  end

  def save(tweets)
    if tweets.instance_of? Array then
      tweets.each do |tw|
        # set user
        user_name = tw[:user_name]
        user = User.find_by_name(user_name)
        unless user then # new user
          user = User.new(name: user_name)
          user.save
        end
        tweet = Tweet.new(:user_id => user.id,
                          :text => tw[:text],
                          :tweeted_at => tw[:tweeted_at],
                          :latitude => tw[:latitude],
                          :longitude => tw[:longitude])
        tweet.save
      end
    elsif tweets.instans_of? Hash then
      tw = tweets
      # set user
      user_name = tw[:user_name]
      user = User.find_by_name(user_name)
      unless user then # new user
        user = User.new(name: user_name)
        user.save
      end
      tweet = Tweet.new(:user_id => user.id,
                        :text => tw[:text],
                        :tweeted_at => tw[:tweeted_at],
                        :latitude => tw[:latitude],
                        :longitude => tw[:longitude])
      tweet.save
    else
      raise "augument must be a hash or an array that contains hash"
    end
  end
  
  def save_from_xml(file_path)    
    begin
      # loading file and storing into hash
      tw_xml = REXML::Document.new(File.new("#{ENV["ROOT"]}/#{file_path}"))
    rescue
      if File.exists? "#{ENV["ROOT"]}/#{file_path}" then
        raise "File has invalid form for xml"
      else
        raise "File does not exist. Augument file_path must be relative path from ENV[\"ROOT\"]."      end
    end
    
    tweets = [] # is an array in which each element has single tweet xml object
    tw_xml.elements.each("//xml/list/tweet") do |tw|
      tweets << {:user_name => tw.elements["user"].attributes["name"],
                 :text => tw.elements["text"].attributes["body"],
                 :tweeted_at => Time.parse(tw.attributes["time"]),
                 :latitude => tw.elements["place"].attributes["latitudeF"],
                 :longitude => tw.elements["place"].attributes["longitudeF"]}
    end

    self.save(tweets)

  end

end
