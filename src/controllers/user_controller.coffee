passport = require 'passport'

models = require '../models'

exports.post_user_create = (req, res) ->
  req.assert('username', 'Username must be at least 3 characters long.').len(3)
  req.assert('password', 'Password must be at least 4 characters long.').len(4)
  req.assert('confirm_password', 'Passwords do not match.').equals(req.body.password)
  errors = req.validationErrors()

  fail = (error) ->
    console.log error
    res.send {ok: false, error: error}

  if errors
    return fail errors

  username = req.body.username
  password = req.body.password
  new_user = models.User.build({username})
  new_user.hash_and_set_password password, (err) ->
    if err?
      return fail "Unable to create account at this time"
    else
      new_user.save().then ->
        req.logIn new_user, (err) ->
          res.send {ok: true, body: {user: new_user.toJSON(), redirect_url: '/'}}
      .catch (error) ->
        console.log error
        return fail 'Username already in use!'

exports.post_user_login = (req, res, next) ->
  req.assert('username', 'Username is not valid.').notEmpty()
  req.assert('password', 'Password cannot be blank.').notEmpty()
  redirect = req.param('redirect')
  redirect_url = decodeURIComponent(redirect) || "/"

  errors = req.validationErrors()
  if errors?
    return res.send {ok: false, error: errors}

  passport.authenticate('local', (err, user, info) ->
    if err?
      return next(err)
    if not user
      return res.send {ok: false, error: 'Could not find user.'}
    req.logIn user, (err) ->
      if err?
        return next err

      res.send {ok: true, body: {redirect_url, user: user.toJSON()}}
  )(req, res, next)

exports.get_user_logout = (req, res) ->
  req.logout()
  res.send {ok: true, body: {redirect_url: '/'}}

exports.post_change_password = (req, res) ->
  req.assert('old_password', 'Old password must be at least 4 characters long.').len(4)
  req.assert('new_password', 'New password must be at least 4 characters long.').len(4)
  req.assert('confirm_password', 'Passwords do not match.').equals(req.param('new_password'))
  errors = req.validationErrors()

  if errors
    return res.send {ok: false, error: errors}

  old_password = req.param('old_password')
  new_password = req.param('new_password')

  fail = (message) ->
    return res.send {ok: false, error: message}

  models.User.find(req.user.id).then (user) ->
    user.compare_password old_password, (err, is_match) ->
      if not is_match or err
        return fail('Current password incorrect');

      user.hash_and_set_password new_password, (err) ->
        if err?
          return fail("Failed to set new password")
        user.save().then () ->
          res.send {ok: true}
        .catch fail
  .catch fail

exports.get_users = (req, res) ->
  userIds = req.param 'userIds'
  models.User.findAll({where: {id: userIds}}).then (users) ->
    userMap = {}
    if not (users instanceof Array)
      users = [users]

    for user in users
      userMap[user.id] = user.toJSON()
    res.send {ok: true, body: {users: userMap}}
  .catch (error) ->
    res.send {ok: false, error: "Failed to retrieve users."}
