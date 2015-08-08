# coding: utf-8
require 'fileutils'
require 'rexml/document'
#require 'json'

# loading files in lib/
ENV["ROOT"] = File.expand_path("..", __FILE__)
$LOAD_PATH << File.expand_path("../lib", __FILE__)
require 'io.rb'


db = DataBase.instance
#db.save_from_xml("ignore/tweet.xml")
users = db.users
tweets =  db.tweets
tweets.each do |tweet|
  #p tweet.id
  #p tweet.user.name
  p tweet.text
  #p tweet.tweeted_at
end
#p user

