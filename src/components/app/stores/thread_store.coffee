Reflux = require 'reflux'
constants = require '../../../lib/common/constants'
{newMessage, loadThreads, bulkLoadMessages, loadThreadCursor} = require '../actions'
MessageNode = require '../lib/message_node'
Notifier = require '../lib/notifier'

ThreadStore = Reflux.createStore
  listenables: [
    {newMessage}
    {loadThreads}
    {bulkLoadMessages}
  ]
  init: ->
    @trees = {}
    # For each thread stores a mapping of message id to message
    @indices = {}
    # For each thread stores a mapping of parent id to message
    @parentIndices = {}
    @data = {}
    @lastUpdate = {}

  _addMessageToTree: (message, previousMessageId) ->
    threadId = message.ThreadId
    if threadId not of @trees
      @trees[threadId] = new MessageNode()
      @indices[threadId] = {}
      @parentIndices[threadId] = {}
      @lastUpdate[threadId] = new Date(message.createdAt)

    if message.id not of @indices[threadId]
      parentId = if message.ParentId then message.ParentId else -1
      newNode = new MessageNode message.id, parentId, previousMessageId
      if parentId not of @indices[threadId] and (
          message.id not of @parentIndices[threadId])
        # If we don't have the previous message, add it as a child of the root
        @trees[threadId].addChild newNode
      else if parentId not of @indices[threadId]
        # This is the case where we have the child but not the parent
        childNode = @parentIndices[threadId][message.id]
        childNode.setNewParent newNode
      else
        # Add this message as a child of its parent
        parentNode = @indices[threadId][parentId]
        parentNode.addChild newNode

      # Update the indices to include the new message
      @indices[threadId][message.id] = newNode
      @parentIndices[threadId][parentId] = newNode
      d = new Date(message.createdAt)
      if d > @lastUpdate[threadId]
        @lastUpdate[threadId] = d

  # Process a new message that came in from a notification
  onNewMessage: (body) ->
    {message, messageData, previousMessage} = body
    threadId = message.ThreadId

    # This is currently needed because threads are lazy loaded
    if threadId not of @data
      loadThreads()

    # Take care of the first message in the thread case
    previousMessageId = if previousMessage then previousMessage.id else null
    @_addMessageToTree(message, previousMessageId)
    @_triggerStateChange([threadId])

  # Load the list of threads for the current user
  onLoadThreads: ->
    $.get('/api/user/threads', (response) =>
      if not response.ok
        return Notifier.error(response.error)

      triggerIds = []
      for thread in response.body.threads
        shouldTrigger = false
        if thread.id not of @data
          # We need to load the messages for this thread too
          @_loadThreadMessages(thread.id)
          triggerIds.push thread.id
        @data[thread.id] = thread

      if triggerIds.length
        @_triggerStateChange(triggerIds)
    )

  # Load the messages for the specified thread
  _loadThreadMessages: (threadId) ->
    $.get('/api/thread/' + threadId + '/messages', (response) =>
      if not response.ok
        return Notifier.error(response.error)

      # Call an action to load the messages in bulk
      bulkLoadMessages(response.body.messages)

      # Call an action to load the cursor for the thread
      loadThreadCursor(threadId)
    )

  onBulkLoadMessages: (messages) ->
    for messageObject in messages
      {message, previousMessageId} = messageObject
      @_addMessageToTree(message, previousMessageId)

    # Trigger an update from the thread store
    if messages.length
      @_triggerStateChange [messages[0].message.ThreadId]

  getThreadNames: () ->
    return @data

  getTree: (threadId) ->
    if threadId not of @trees
      return null

    return @trees[threadId]

  # Given a cursor, determine if the thread has been updated since then or not
  hasBeenUpdated: (cursor, threadId) ->
    if threadId not of @lastUpdate
      return false
    d = new Date(cursor.viewTime)
    return d < @lastUpdate[threadId]

  _triggerStateChange: (threadIdList) ->
    @trigger threadIdList

module.exports = ThreadStore
