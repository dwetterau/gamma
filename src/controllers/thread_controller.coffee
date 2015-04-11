{Thread, User} = require '../models'

exports.post_create_thread = (req, res) ->
  req.assert('name', 'Thread name is not valid.').notEmpty()
  fail = (errors) ->
    res.send {ok: false, error: errors}
  errors = req.validationErrors()
  if errors?
    return fail errors

  initialMembers = req.param 'members'

  # Add req.user to the list of members if not in it already
  includedSelf = false
  if not initialMembers?
    initialMembers = [req.user.username]
  else
    for member in initialMembers
      if req.user.username == member
        includedSelf = true
        break

    if not includedSelf
      initialMembers.push req.user.username

  threadName = req.param('name')
  newThread = null
  members = null
  User.findAll({where: [username: initialMembers]}).then (allMembers) ->
    if allMembers.length != initialMembers.length
      throw "Invalid member specified."

    members = allMembers
    return Thread.create(displayName: threadName)
  .then (thread) ->
    newThread = thread
    return thread.setMembers members
  .then ->
    res.send {ok: true, body: {thread: newThread.toJSON()}}
  .catch fail

exports.get_messages_for_thread = (req, res) ->
  req.assert('threadId', 'Invalid thread id.').notEmpty().isInt()
  fail = (error) ->
    console.log error
    res.send {ok: false, error}

  errors = req.validationErrors()
  if errors?
    return fail errors

  req.user.getThreads({where: {id: req.param('threadId')}}).then (thread) ->
    if not thread?
      throw "User not allowed to retrieve messages for this thread."
    # Limit the number of messages returned, default to 50 latest
    console.log thread
    return thread.getMessages({limit: 50})
  .then (messages) ->
    res.send {ok: true, body: {messages}}
  .catch fail