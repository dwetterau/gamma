Reflux = require 'reflux'
constants = require '../../../lib/common/constants'
{newThread} = require '../actions'

MessageStore = Reflux.createStore
  listenables: [
    {newThread}
  ]
  init: ->
    @threads = {}

  hasThread: (threadId) ->
    return threadId of @threads

  onNewThread: (threadId) ->
    # TODO send out request for thread details?
    @threads[threadId] = true

    @_triggerStateChange()

  _triggerStateChange: ->
    @trigger @threads

module.exports = MessageStore
