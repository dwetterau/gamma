
# This is the in-memory map of notifications for sending out in real-time
_pendingNotifications = {}
_currentListeners = {}

_pushNotification = (userId, notification) ->
  if userId of _pendingNotifications
    _pendingNotifications[userId].push notification
  else
    _pendingNotifications[userId] = [notification]

  # Kill the timeout loop and send notification immediately if listening
  if userId of _currentListeners
    clearTimeout listenLoop
    _listenLoopFunc()

exports.new_message_for_user (message, userId) ->
  # TODO Move this type constant somewhere
  notification = {type: 'New Message', body: {message}}
  _pushNotification userId, notification

_notifyFunc = ->
  for userId, notifications of _pendingNotifications
    if userId of _currentListeners
      for res in _currentListeners[userId]
        try
          res.send notifications
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


