# gems
```
bundle install --path vendor/bundle
```
# database operations
Using rakefile
```
rake db:migrate
rake db:rollback
rake db:drop
```
or directly make instance of class DataBase
```
db = DataBase.instance
```
To save database
```
tweet = {:user => username
         :text => body of tweet
         :tweeted_at => tweet time
         :latitude => latitude
         :longitude => lingitude}
db.save(tweet)
```
or
```
tweets = [tweet, tweet]
tweets = db.save(tweets)
```
to get data from database
```
tweets = db.tweets
tweets.each do |tweet|
  do something
end
```
# Memo
## Newline character conversion
* UNIX => DOS
```
ruby -i -pe 'sub("\n", "\r\n")' DirName/**/*(.)
```
* DOS => UNIX
```
ruby -i -pe 'sub("\r", "")' DirName/**/*(.)
```
