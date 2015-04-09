{Thread} = require '../models'

exports.post_create_thread = (req, res) ->
  req.assert('name', 'Thread name is not valid.').notEmpty()
  fail = (errors) ->
    res.send {ok: false, error: errors}

  errors = req.validationErrors()
  if errors?
    return fail errors

  threadName = req.param('name')
  newThread = null
  Thread.create(displayName: threadName).then (thread) ->
    newThread = thread
    return req.user.addThread thread
  .then ->
    res.send {ok: true, body: {thread: newThread.toJSON()}}
  .catch fail
