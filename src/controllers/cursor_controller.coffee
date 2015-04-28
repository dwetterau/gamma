{Cursor, Thread, User} = require '../models'

exports.get_or_create_cursor = (req, res) ->
  req.assert('threadId', 'Thread id is not valid.').notEmpty().isInt()
  fail = (errors) ->
    res.send {ok: false, error: errors}
  success = (cursor) ->
    res.send {ok: true, body: {cursor}}

  errors = req.validationErrors()
  if errors?
    return fail errors

  Cursor.find({where: {ThreadId: req.param('threadId'), UserId: req.user.id}}).then (cursor) ->
    if cursor
      return success cursor
    else
      return Thread.find({
        where: {id: req.param('threadId')},
        include: [{model: User, as: 'Members'}]})
      .then (thread) ->
        if not thread
          throw 'Could not find thread.'

        foundUser = false
        for user in thread.Members
          if user.id == req.user.id
            foundUser = true
            break

        if not foundUser
          throw 'User not in this thread.'

        return Cursor.create({
          viewTime: new Date(0)
          UserId: req.user.id
          ThreadId: parseInt req.param('threadId'), 10
        })
      .then success
  .catch fail

exports.post_update_cursor = (req, res) ->
  req.assert('cursorId', 'Cursor id is not valid').notEmpty().isInt()
  req.assert('viewTime', 'Cursor view time is not valid').notEmpty().isDate()
  fail = (errors) ->
    console.log errors
    res.send {ok: false, error: errors}
  success = (cursor) ->
    res.send {ok: true, body: {cursor}}

  errors = req.validationErrors()
  if errors?
    return fail errors

  Cursor.find(req.param('cursorId')).then (cursor) ->
    if not cursor
      throw "Could not find cursor."

    if cursor.UserId != req.user.id
      throw "Could not find cursor."

    cursor.viewTime = new Date(req.param('viewTime'))
    return cursor.save()
  .then success
  .catch fail
