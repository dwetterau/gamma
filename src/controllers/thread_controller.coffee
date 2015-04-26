{MessageData, Thread, User} = require '../models'

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

  if req.param('limit')
    # Limit the number of messages returned, default to 50 latest
    limit = Math.min parseInt(req.param('limit'), 10), 50
  else
    limit = 50

  # This is to get the id of the message before the first one
  # that we will return.
  limit++

  req.user.getThreads({where: {id: req.param('threadId')}}).then (thread) ->
    if not thread?
      throw "User not allowed to retrieve messages for this thread."


    if req.param('offset')
      offset = req.param('offset')
    else
      offset = 0
    where = {hidden: false}

    return thread[0].getMessages {
      limit
      offset
      order: 'createdAt DESC'
      where
      include: [MessageData]
    }
  .then (messages) ->
    messagesToSend = new Array(limit - 1)
    for i in [0...limit - 1]
      message = messages[i]
      # TODO: Figure out a better (de)serialization story for message data
      message.MessageDatum.value =
        String.fromCharCode.apply(null, new Uint16Array(message.MessageDatum.value))

      # The previous message is the next message in the list because of the serializable
      # setting of the DB.
      previousMessageId = messages[i + 1].id

      messagesToSend[i] = {message, previousMessageId}

    res.send {ok: true, body: {messages: messagesToSend}}
  .catch fail

exports.get_threads_for_user = (req, res) ->
  fail = (error) ->
    console.log error
    res.send {ok: false, error}

  errors = req.validationErrors()
  if errors?
    return fail errors

  req.user.getThreads().then (threads) ->
    res.send {ok: true, body: {threads}}
  .catch fail