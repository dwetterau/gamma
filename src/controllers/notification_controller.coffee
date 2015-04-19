{Thread, User} = require '../models'

# This is the in-memory map of notifications for sending out in real-time
_pendingNotifications = {}
_currentListeners = {}
listenLoop = null

_pushNotification = (userId, notification) ->
  if userId of _pendingNotifications
    _pendingNotifications[userId].push notification
  else
    _pendingNotifications[userId] = [notification]

  # Kill the timeout loop and send notification immediately if listening
  if userId of _currentListeners
    return true
  else
    return false

_pushPendingNotifications = ->
  clearTimeout listenLoop
  _listenLoopFunc()

exports.newMessageNotification = (message, messageData, previousMessage, threadId) ->
  # TODO Move this type constant somewhere
  notification = {type: 'New Message', body: {message, messageData, previousMessage}}
  Thread.find({
    where: {id: threadId},
    include: [{model: User, as: 'Members'}]})
  .then (thread) ->
    if not thread
      # Don't make the notification, thread no longer exists
      return

    shouldFlush = false
    for user in thread.Members
      shouldFlush = shouldFlush or _pushNotification user.id, notification
    if shouldFlush
      _pushPendingNotifications()

_notifyFunc = ->
  for userId, notifications of _pendingNotifications
    if userId of _currentListeners and notifications.length > 0
      for res in _currentListeners[userId]
        try
          res.send notifications
          _pendingNotifications[userId] = []
        catch
          # Listener stopped, run the unable to push notification routine
      delete _currentListeners[userId]

_listenLoopFunc = ->
  _notifyFunc()
  listenLoop = setTimeout ->
    _listenLoopFunc()
  , 10000 # TODO Move this constant

exports.startNotificationServer = ->
  _listenLoopFunc()

exports.get_listen_notifications = (req, res) ->
  # Put the response object in the listeners map
  if req.user.id of _currentListeners
    _currentListeners[req.user.id].push res
  else
    _currentListeners[req.user.id] = [res]


