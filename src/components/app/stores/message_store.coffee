Reflux = require 'reflux'
constants = require '../../../lib/common/constants'
notificationStore = require './notification_store'

MessageStore = Reflux.createStore

  init: ->
    @messages = {}
    # Start listening for notifications
    notificationStore.listen @_onNotificationStoreUpdate

  _onNotificationStoreUpdate: (notifications) ->
    for notification in notifications
      shouldTrigger = false
      if notification.type == constants.NOTIFICATION_TYPE_NEW_MESSAGE
        {message, messageData, previousMessage} = notification.body
        if message.id not of @messages
          message.MessageDatum = messageData
          @messages[message.id] = {message, messageData, previousMessage}
          shouldTrigger = true

    if shouldTrigger
      @_triggerStateChange()

  _triggerStateChange: ->
    @trigger @messages

module.exports = MessageStore
