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
    @threadMessageMap = {}

  _addMessageToThread: (messageId, threadId) ->
    if threadId not of @threadMessageMap
      @threadMessageMap[threadId] = []

    @threadMessageMap[threadId].push messageId

  onNewMessage: (body) ->
    {message, messageData, previousMessage} = body
    if previousMessage.id not of @messages
      # Insert a temporary entry for the previous message with metadata
      @messages[previousMessage.id] = {metadata: previousMessage, full: false}

    @messages[message.id] = {metadata: message, data: messageData, previousMessageId: previousMessage.id, full: true}
    @_addMessageToThread(message.id, message.ThreadId)
    @_triggerStateChange(message.id)

  onBulkLoadMessages: (messages) ->
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
      @_addMessageToThread(message.id, message.ThreadId)
      @_triggerStateChange(message.id)

  hasFullMessage: (messageId) ->
    return messageId of @messages and @messages[messageId].full

  getMessage: (messageId) ->
    if messageId not of @messages
      return null

    return @messages[messageId]

  getMessagesForThread: (threadId) ->
    if threadId not of @threadMessageMap
      return {}

    messages = {}
    for messageId in @threadMessageMap[threadId]
      messages[messageId] = @getMessage(messageId)
    return messages

  _triggerStateChange: (messageId) ->
    @trigger messageId

module.exports = MessageStore
