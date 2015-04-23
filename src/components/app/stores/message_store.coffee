Reflux = require 'reflux'
constants = require '../../../lib/common/constants'
{newMessage} = require '../actions'

MessageStore = Reflux.createStore
  listenables: [
    {newMessage}
  ]
  init: ->
    @messages = {}

  onNewMessage: (body) ->
    {message, messageData, previousMessage} = body
    if previousMessage.id not of @messages
      # Insert a temporary entry for the previous message with metadata
      @messages[previousMessage.id] = {metadata: previousMessage}

    @messages[message.id] = {metadata: message, data: messageData, previousId: previousMessage.id}
    @_triggerStateChange()

  _triggerStateChange: ->
    @trigger @messages

module.exports = MessageStore
