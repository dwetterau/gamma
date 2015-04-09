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
