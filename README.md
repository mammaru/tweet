# Newline character
* UNIX => DOS
```
ruby -i -pe 'sub("\n", "\r\n")' lib/**/*(.)
```
* DOS => UNIX
```
ruby -i -pe 'sub("\r", "")' lib/**/*(.)
```
# gem
```
bundle install --path vendor/bundle
```
# database
```
rake db:migrate
```
```
rake db:rollback
```
```
rake db:drop
```

