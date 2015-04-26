passport = require 'passport'
LocalStrategy = require 'passport-local'

models = require '../models'

passport.serializeUser (user, done) ->
  done null, user.id

passport.deserializeUser (id, done) ->
  models.User.find(id).then (user) ->
    done null, user
  .catch (err) ->
    done err

passport.use new LocalStrategy {usernameField: 'username'}, (username, password, done) ->
  models.User.find({where: {username}}).then (user) ->
    if not user
      return done null, false, {message: 'Invalid username or password.'}
    user.compare_password password, (err, is_match) ->
      if is_match
        return done null, user
      else
        return done null, false, {message: 'Invalid username or password.'}

exports.isAuthenticated = (req, res, next) ->
  if req.isAuthenticated()
    return next()
  if req.url.indexOf '/api' == 0
    res.send {ok: false, error: "User not logged in."}
  else
    res.redirect '/user/login?r=' + encodeURIComponent(req.url)
