{Message, MessageData, User} = require '../models'
notificationController = require './notification_controller'

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
    newMessage = message
    newMessageData.MessageId = message.id
    return newMessageData.save()
  .then ->
    # We need to send a notification to all clients in this thread with this message, and the id of the message
    # in this thread that comes right before this one in the serializable DB.
    return Message.find({
      limit: 1,
      where:
        ThreadId: thread.id,
        id:
          $lt: newMessage.id
      order: 'id DESC'
    })
  .then (beforeMessage) ->
    # beforeMessage is either null (no message before) or the message that should
    # be displayed before this new one. This is used to enforce causal ordering for
    # the chat clients.
    notificationController.newMessageNotification newMessage, newMessageData, beforeMessage, thisThread
    success newMessage
  .catch fail

exports.delete_message = (req, res) ->
  req.assert('messageId', 'Invalid message id.').notEmpty().isInt()
  fail = (errors) ->
    res.send {ok: false, error: errors}

  errors = req.validationErrors()
  if errors?
    return fail errors

  messageMeta = null
  Message.find(req.param('messageId')).then (message) ->
    if message.AuthorId != req.user.id
      throw 'User not allowed to delete message'

    messageMeta = message
    return MessageData.destroy({where: {MessageId: message.id}})
  .then ->
    return messageMeta.update({hidden: true})
  .then ->
    res.send {status: 'ok', body: {}}
  .catch fail
