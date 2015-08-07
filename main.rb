# coding: utf-8
require 'time'
#require "active_support/core_ext/hash/conversions"
require 'fileutils'
require 'rexml/document'
#require 'json'
require 'sqlite3'

# loading files in lib/
$LOAD_PATH << File.expand_path('../lib', __FILE__)
require 'models.rb'

# loading file and storing into hash
tw_xml = REXML::Document.new(File.new("./ignore/tweet.xml"))
@tweets = [] # is an array in which each element has single tweet xml object
tw_xml.elements.each("//xml/list/tweet") do |t|
  @tweets << t #Hash.from_xml(t.to_s)
end

p @tweets
@tweets.each do |tw|

  # set user
  user_name = tw.elements["user"].attributes["name"]
  p user_name
  user = User.find_by_name(user_name)
  unless user then
    user = User.new(name: user_name)
    user.save
  end

  # set tweet
  tweet = Hash.new
  tweet["user_id"] = user.id
  tweet["body"] = tw.elements["text"].attributes["body"]
  tweet["tweeted_at"] = Time.parse(tw.attributes["time"])
  tweet["latitude"] = tw.elements["place"].attributes["latitudeF"]
  tweet["longitude"] = tw.elements["place"].attributes["longitudeF"]
  
  tweet = Tweet.new(tweet)
  tweet.save
  
end
