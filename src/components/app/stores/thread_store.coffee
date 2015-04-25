Reflux = require 'reflux'
constants = require '../../../lib/common/constants'
{newMessage} = require '../actions'
MessageNode = require '../lib/message_node'

MessageStore = Reflux.createStore
  listenables: [
    {newMessage}
  ]
  init: ->
    @trees = {}
    @indices = {}

  onNewMessage: (body) ->
    {message, messageData, previousMessage} = body
    threadId = message.ThreadId
    if threadId not of @trees
      @trees[threadId] = new MessageNode()
      @indices[threadId] = {}

    if message.id not of @indices[threadId]
      newNode = new MessageNode message.id, previousMessage.id
      if previousMessage.id not of @indices[threadId]
        # If we don't have the previous message, add it as a child of the root
        @trees[threadId].addChild newNode
      else
        # Add this message as a child of its parent
        parentNode = @indices[threadId][previousMessage.id]
        parentNode.addChild newNode

      # Update the index to include the new message
      @indices[threadId][message.id] = newNode

    @_triggerStateChange(threadId)

  getTree: (threadId) ->
    if threadId not of @trees
      return null

    return @trees[threadId]

  _triggerStateChange: (threadId) ->
    @trigger threadId

module.exports = MessageStore
