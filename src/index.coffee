bodyParser = require 'body-parser'
busboy = require 'connect-busboy'
cookieParser = require 'cookie-parser'
express = require 'express'
favicon = require 'serve-favicon'
flash = require 'express-flash'
logger = require 'morgan'
methodOverride = require 'method-override'
path = require 'path'
validator = require 'express-validator'

session = require 'express-session'
MySQLStore =  require('connect-mysql')(session)

passport_config = require './lib/auth'
passport = require 'passport'

{ config } = require './lib/common'

all_routes = require './routes/routes'

index_controller = require './controllers/index_controller'

app = express()

# view engine setup
app.set 'views', path.join(__dirname, 'views')
app.set 'view engine', 'jade'

app.use favicon(__dirname + '/public/favicon.ico')
app.use logger('dev')
app.use busboy()
app.use bodyParser.json()
app.use bodyParser.urlencoded {extended: true}
app.use validator()
app.use methodOverride()
app.use cookieParser()

app.use express.static(path.join(__dirname, '/public'))

# Setup sessions
app.use session
  resave: true
  saveUninitialized: true
  store: new MySQLStore(
    config:
      user: config.get("db_username")
      password: config.get("db_password")
      database: config.get("database")
  )
  secret: config.get('session_secret')
app.use flash()
app.use passport.initialize()
app.use passport.session()

# Setup all the routes
app.use '/', all_routes

# Handle the HTML5 links the right way
app.use (req, res, next) ->
  if req.path.indexOf '/api' != 0
    return index_controller.get_index req, res

  # catch 404 and forward to error handler
  err = new Error('404 Page Not Found')
  err.status = 404
  next(err)

if app.get('env') == 'local'
  # development error handler
  # will print stacktrace in local mode
  app.use (err, req, res, next) ->
    res.status(err.status || 500)
    errorObj =
      message: err.message
      error: err
      title: 'Error'
      user: req.user
    res.render('error', errorObj)
else
  # production error handler
  # no stacktraces leaked to user
  app.use (err, req, res, next) ->
    res.status(err.status || 500)
    errorObj =
      message: err.message
      error: {}
      title: 'Error'
      user: req.user
    res.render('error', errorObj)

app.listen(config.get('PORT'))

module.exports = app
