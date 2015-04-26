Reflux = require 'reflux'
constants = require '../../../lib/common/constants'
{newMessage} = require '../actions'

NotificationStore = Reflux.createStore

  init: ->
    @state = {
      threadUnread: {}
    }
    # Start listening for notifications
    @_request_notifications()

  _request_notifications: ->
    $.get('/api/notifications', (response) =>
      if response.ok
        @_add_notifications response.body
        @_request_notifications()
      else
        setTimeout =>
          @_request_notifications()
        , constants.NOTIFICATION_RETRY_TIMEOUT
    )

  _add_notifications: (notifications) ->
    shouldTrigger = false
    for notification in notifications
      if notification.type == constants.NOTIFICATION_TYPE_NEW_MESSAGE
        threadId = notification.body.message.ThreadId
        if not @state.threadUnread[threadId]
          @state.threadUnread[threadId] = true
          shouldTrigger = true
        newMessage(notification.body)

    if shouldTrigger
      @_triggerStateChange()

  _triggerStateChange: ->
    console.log "Triggering!"
    @trigger @notifications

module.exports =  NotificationStore
