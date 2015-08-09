# Gems
```
bundle install --path vendor/bundle
```
# Usages
## database operations and make instance
Using rakefile
```
rake db:migrate
rake db:rollback
```
and make instance of class DataBase. If database does not exist, instance is initialized with migration.
```
# header of main.rb
ENV["ROOT"] = File.expand_path("..", __FILE__)
ENV["ENV"] = "development"
$LOAD_PATH << File.expand_path("../lib", __FILE__)
require 'io.rb'

# make instance of DB
db = DataBase.instance
```
## save data
To save tweet into database, make hash of tweet data and save
```
tweet = {:user => username,
         :text => body of tweet,
         :tweeted_at => tweet time,
         :latitude => latitude,
         :longitude => lingitude,
         :place => place name}
db.save(tweet)
```
or array of hashes is allowed
```
tweets = [tweet1, tweet2, ...]
db.save(tweets)
```
## use data
To get data from database
```
tweets = db.tweets
tweets.each do |tweet|
  do something like
  p tweet.user.name
  p tweet.text
  puts "------"
end

users = db.users
users.each do |user|
  p user.name
  user.tweets.each do |tweet|
    p tweet.text
  end
  puts "------"
end
```
