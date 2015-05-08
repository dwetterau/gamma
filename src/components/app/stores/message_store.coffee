Reflux = require 'reflux'
constants = require '../../../lib/common/constants'
{newMessage, bulkLoadMessages} = require '../actions'
threadStore = require './thread_store'

MessageStore = Reflux.createStore
  listenables: [
    {newMessage}
    {bulkLoadMessages}
  ]
  init: ->
    @messages = {}

  onNewMessage: (body) ->
    {message, messageData, previousMessage} = body
    previousMessageId = if previousMessage then previousMessage.id else -1
    if previousMessageId not of @messages and previousMessage
      # Insert a temporary entry for the previous message with metadata
      @messages[previousMessageId] = {metadata: previousMessage, full: false}

    @messages[message.id] = {metadata: message, data: messageData, previousMessageId: previousMessageId, full: true}
    @_triggerStateChange([message.id])

  onBulkLoadMessages: (messages) ->
    updated = []
    for messageObject in messages
      {message, previousMessageId} = messageObject

      if previousMessageId not of @messages
        # Put a stub entry for the previousMessageId
        @messages[previousMessageId] = {full: false}

      data = message.MessageDatum
      delete message.MessageDatum

      @messages[message.id] = {
        metadata: message,
        data,
        previousMessageId,
        full: true
      }
      updated.push message.id
    @_triggerStateChange(updated)

  hasFullMessage: (messageId) ->
    return messageId of @messages and @messages[messageId].full

  getMessage: (messageId) ->
    if messageId not of @messages
      return null

    return @messages[messageId]

  _triggerStateChange: (messageIds) ->
    @trigger messageIds

module.exports = MessageStore
