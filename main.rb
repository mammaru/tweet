# coding: utf-8
require 'time'
#require "active_support/core_ext/hash/conversions"
require 'fileutils'
require 'rexml/document'
#require 'json'
require 'mysql2'

# loading files
$LOAD_PATH << './lib'
require 'models.rb'
require 'io.rb'

# loading file and storing into hash
tw_xml = REXML::Document.new(File.new("./ignore/tweet.xml"))
@tweets = []
tw_xml.elements.each("//xml/list/tweet") do |t|
  @tweets << t #Hash.from_xml(t.to_s)
end

# cnnection to database
config = YAML.load_file("./ignore/database.yml")
ActiveRecord::Base.establish_cnnection(config["db"]["development"])

@tweets.each do |tw|
  user_name = tw.elements["user"].attributes["name"]
  body = tw.elements["text"].attributes["body"]
  tweeted_at = Time.parse(tw.attributes["time"])
  body = tw.elements["text"].attributes["body"]
  
  tweet = Tweet.new
  if User.find_by_name(user_name)
    user = User.new
    user.name = user_name
    user.save
    tweet.user_id = User.find_by_name(user_name)
  else
    tweet.user_id = User.find_by_name(user_name)
  end
  tweet.tweeted_at = tweeted_at
  tweet.body = body
  
end
