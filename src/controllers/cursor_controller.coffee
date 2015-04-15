{Cursor, Thread, User} = require '../models'

exports.get_or_create_cursor = (req, res) ->
  req.assert('threadId', 'Thread name is not valid.').notEmpty().isInt()
  fail = (errors) ->
    res.send {ok: false, error: errors}
  success = (cursor) ->
    console.log cursor
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
