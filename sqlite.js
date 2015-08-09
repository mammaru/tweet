var sqlt = require('sqlite3-webapi-kit');
sqlt.open('db/development.sqlite3', function (err) {
  sqlite3.listen(4983, function () {
    console.log('server start');
  });
});
