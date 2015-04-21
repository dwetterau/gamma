Reflux = require 'reflux'

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
        # TODO: Move constant
        setTimeout =>
          @_request_notifications()
        , 5000
    )

  _add_notifications: (notifications) ->
    for notification in notifications
      @notifications.push notification
    @_triggerStateChange()

  _triggerStateChange: ->
    console.log (@notifications)
    @trigger @notifications

module.exports =  NotificationStore
