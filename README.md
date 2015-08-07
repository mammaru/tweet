# gems
```
bundle install --path vendor/bundle
```
# database operations
```
rake db:migrate
```
```
rake db:rollback
```
```
rake db:drop
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
