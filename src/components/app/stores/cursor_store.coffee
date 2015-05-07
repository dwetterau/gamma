Reflux = require 'reflux'
{loadThreadCursor} = require '../actions'

CursorStore = Reflux.createStore
  listenables: [
    {loadThreadCursor}
  ]
  init: ->
    @data = {}

  # Load the messages for the specified thread
  onLoadThreadCursor: (threadId) ->
    $.get('/api/thread/' + threadId + '/cursor', (response) =>
      if response.ok
        @data[threadId] = response.body.cursor
        @_triggerStateChange(threadId)
    )

  getCursor: (threadId) ->
    if threadId not of @data
      return null

    return @data[threadId]

  updateCursor: (threadId, viewTime) ->
    if threadId not of @data
      return

    cursorId = @data[threadId].id
    $.post('/api/cursor/' + cursorId + '/update', {viewTime}).then (response) =>
      if response.ok
        @data[threadId] = response.body.cursor
        @_triggerStateChange(threadId)

  _triggerStateChange: (threadId) ->
    @trigger threadId

module.exports = CursorStore
