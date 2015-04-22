Reflux = require 'reflux'
constants = require '../../../lib/common/constants'

NotificationStore = Reflux.createStore

  init: ->
    @notifications = []
    # Start listening for notifications
    @_request_notifications()

  _request_notifications: ->
    $.get('/notifications', (response) =>
      if response.ok
        @_add_notifications response.body
        @_request_notifications()
      else
        setTimeout =>
          @_request_notifications()
        , constants.NOTIFICATION_RETRY_TIMEOUT
    )

  _add_notifications: (notifications) ->
    for notification in notifications
      @notifications.push notification
    @_triggerStateChange()

  _triggerStateChange: ->
    console.log "Triggering!"
    @trigger @notifications

module.exports =  NotificationStore
