Reflux = require 'reflux'
constants = require '../../../lib/common/constants'
{newMessage} = require '../actions'
threadStore = require './thread_store'

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
      @messages[previousMessage.id] = {metadata: previousMessage, full: false}

    @messages[message.id] = {metadata: message, data: messageData, previousId: previousMessage.id, full: true}
    @_triggerStateChange(message.id)

  hasFullMessage: (messageId) ->
    return messageId of @messages and @messages[messageId].full

  getMessage: (messageId) ->
    if messageId not of @messages
      return null

    return @messages[messageId]

  _triggerStateChange: (messageId) ->
    @trigger messageId

module.exports = MessageStore
