# coding: utf-8
require 'time'
#require "active_support/core_ext/hash/conversions"
require 'fileutils'
require 'rexml/document'
#require 'json'
require 'sqlite3'

# loading files in lib/
$LOAD_PATH << File.expand_path("..", __FILE__) unless $LOAD_PATH.include? File.expand_path("..", __FILE__)
require 'models.rb'


class DataBase
  include Singleton

  def initialize
    # retrieve connection to database
    @db = "db"
    @env = "development"
    @dbconfig = YAML::load(File.open("#{ENV["ROOT"]}/config/database.yml"))[@db][@env]
    ActiveRecord::Base.establish_connection(@dbconfig)
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
    tweets.each do |tw|
      # set user
      user_name = tw[:user_name]
      #p user_name
      user = User.find_by_name(user_name)
      unless user then
        user = User.new(name: user_name)
        user.save
      end
      tweet = Tweet.new(:user_id => user.id,
                        :body => tw[:body],
                        :tweeted_at => tw[:tweeted_at],
                        :latitude => tw[:latitude],
                        :longitude => tw[:longitude])
      tweet.save
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
                 :body => tw.elements["text"].attributes["body"],
                 :tweeted_at => Time.parse(tw.attributes["time"]),
                 :latitude => tw.elements["place"].attributes["latitudeF"],
                 :longitude => tw.elements["place"].attributes["longitudeF"]}
    end

    self.save(tweets)

  end

end
