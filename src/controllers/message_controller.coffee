{Message, MessageData, User} = require '../models'

exports.post_create_message = (req, res) ->
  req.assert('type', 'Invalid message type.').notEmpty().isInt()
  req.assert('threadId', 'Invalid thread id.').notEmpty().isInt()
  fail = (errors) ->
    res.send {ok: false, error: errors}

  success = (message) ->
    res.send {ok: true, body: {message}}

  int = (string) ->
    if string?
      parseInt string, 10
    else
      null

  errors = req.validationErrors()
  if errors?
    return fail errors

  # First make sure that req.user is in the thread
  thisThread = req.param('threadId')
  newMessageData = null
  newMessage = null
  thread = null
  parentId = req.param('parentId')

  checkParent = req.param('parentId')
  req.user.getThreads({where: {id: thisThread}}).then (threads) ->
    # This should only return the one thread we're interested in
    if threads.length == 1
      thread = threads[0]

    if not thread
      throw 'User not allowed to post in this thread.'
  .then ->
    # Make sure if parentId is specified, it both exists and is in the same thread
    if parentId?
      return Message.find({where: {id: parentId}}).then (parentMessage) ->
        if not parentMessage or parentMessage.ThreadId != thread.id
          throw "Invalid parent message specified"
  .then ->
    # Create the message data
    return MessageData.create({value: req.param('content')})
  .then (messageData) ->
    console.log "here1"
    newMessageData = messageData
    return Message.create
      hidden: false
      type: int req.param('type')
      AuthorId: req.user.id
      UserId: req.user.id
      ParentId: int req.param('parentId')
      MessageId: int req.param('parentId')
      ThreadId: thread.id
  .then (message) ->
    console.log "2"
    newMessage = message
    newMessageData.MessageId = message.id
    return newMessageData.save()
  .then ->
    console.log "3"
    success newMessage
  .catch fail
