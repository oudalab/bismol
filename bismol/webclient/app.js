var express = require('express');
var path = require('path');
var favicon = require('serve-favicon');
var logger = require('morgan');
var cookieParser = require('cookie-parser');
var bodyParser = require('body-parser');
var r = require('rethinkdb');
var routes = require('./routes/index');
var sockio = require('socket.io');
var app = express();

// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'jade');

// uncomment after placing your favicon in /public
//app.use(favicon(path.join(__dirname, 'public', 'favicon.ico')));
app.use(logger('dev'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

app.use('/', routes);

var io = sockio.listen(app.listen(8099), {log: false});
console.log("server started on port " + 8099);

// catch 404 and forward to error handler
app.use(function(req, res, next) {
  var err = new Error('Not Found');
  err.status = 404;
  next(err);
});

io.on('connection', function(socket){
  r.table('messages').run(connection, function(err, cursor) {
        if (err) throw err;
        cursor.toArray(function(err, result) {
          if (err) throw err;
          io.emit('connected', result);
        });
  });

  socket.on('point changed', function(data) {
    //console.log(data);
    data['modified_by'] = 'client';
    r.table('messages').insert(data, { conflict: 'update' }).run(connection, function() {
      console.log('updated user point');
    });
  });

  var sampleData = [
		{'lat': 33.397, 'long': -100.644, 'title': 'Test status 1', 'dateTime': 'Today'},
		{'lat': 34.397, 'long': -100.644, 'title': 'Test status 2', 'dateTime': 'Today'},
		{'lat': 35.397, 'long': -100.644, 'title': 'Test status 3', 'dateTime': 'Today'},
		{'lat': 36.397, 'long': -100.644, 'title': 'Test status 4', 'dateTime': 'Today'},
		{'lat': 37.397, 'long': -100.644, 'title': 'Test status 5', 'dateTime': 'Today'},
		{'lat': 38.397, 'long': -100.644, 'title': 'Test status 6', 'dateTime': 'Today'},
		{'lat': 39.397, 'long': -100.644, 'title': 'Test status 7', 'dateTime': 'Today'},
		{'lat': 40.397, 'long': -100.644, 'title': 'Test status 8', 'dateTime': 'Today'},
		{'lat': 41.397, 'long': -100.644, 'title': 'Test status 9', 'dateTime': 'Today'},
		{'lat': 42.397, 'long': -100.644, 'title': 'Test status 10', 'dateTime': 'Today'},
		{'lat': 43.397, 'long': -100.644, 'title': 'Test status 11', 'dateTime': 'Today'},
		{'lat': 44.397, 'long': -100.644, 'title': 'Test status 12', 'dateTime': 'Today'},
		{'lat': 45.397, 'long': -100.644, 'title': 'Test status 13', 'dateTime': 'Today'},
		{'lat': 46.397, 'long': -100.644, 'title': 'Test status 14', 'dateTime': 'Today'}]

  var counter = 0;
  
  setInterval(function() {
    if (counter < 12) {
      io.emit('newPoints', sampleData[counter]);
      counter++;
    } else {
      clearInterval();
    }
  }, 1000);
});

// Connect to rethinkdb
var connection = null;
r.connect( {host: 'localhost', port: 28015, db: 'messagedb'}, function(err, conn) {
    if (err) throw err;
    connection = conn;
    // Set up changefeed on messages table
    r.table('messages').changes().run(connection, function(err, cursor) {
        if (err) throw err;
        cursor.each(function(err, row) {
            if (err) throw err;
            //console.log(JSON.stringify(row, null, 2));
            if(row['new_val'] !== null) {
              if (row['new_val']['modified_by'] === 'server') {
                io.emit('dbchanged', row);
              }
            }
        });
    });
});

// error handlers

// development error handler
// will print stacktrace
if (app.get('env') === 'development') {
  app.use(function(err, req, res, next) {
    res.status(err.status || 500);
    res.render('error', {
      message: err.message,
      error: err
    });
  });
}

// production error handler
// no stacktraces leaked to user
app.use(function(err, req, res, next) {
  res.status(err.status || 500);
  res.render('error', {
    message: err.message,
    error: {}
  });
});


module.exports = app;
