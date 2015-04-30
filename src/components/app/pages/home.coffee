React = require 'react'
cursorStore = require '../stores/cursor_store'
messageStore = require '../stores/message_store'
notificationStore = require '../stores/notification_store'
threadStore = require '../stores/thread_store'
userSessionStore = require '../stores/user_session_store'

# Actions this page can make
{loadThreads} = require '../actions'

Home = React.createClass
  getInitialState: ->
    user = userSessionStore.getUser()
    state = {
      threadTrees: {}
      messages: {}
    }
    if user?
      state.user = user

    return state

  _onUserSessionUpdate: (user) ->
    @setState {user}

  _onThreadStoreUpdate: (threadIds) ->
    if 'threadNames' not of @state
      threadNames = threadStore.getThreadNames()
      @setState {threadNames}
    else
      threadTrees = @state.threadTrees
      for threadId in threadIds
        threadTrees[threadId] = threadStore.getTree threadId
      @setState {threadTrees}


  _onCursorStoreUpdate: (threadId) ->
    console.log "Got cursor for threadId: ", threadId, cursorStore.getCursor(threadId)

  _onMessageStoreUpdate: (messageId) ->
    # TODO: Do something smarter here.
    messages = @state.messages
    messages[messageId] = messageStore.getMessage(messageId)
    @setState {messages}

  componentDidMount: ->
    @unsubscribeFromCursorStore = cursorStore.listen(@_onCursorStoreUpdate)
    @unsubscribeFromMessageStore = messageStore.listen(@_onMessageStoreUpdate)
    @unsubscribeFromThreadStore = threadStore.listen(@_onThreadStoreUpdate)
    @unsubscribeFromUserSessionStore = userSessionStore.listen(@_onUserSessionUpdate)

    # Load all threads for the user
    loadThreads()

  componentWillUnmount: ->
    @unsubscribeFromCursorStore()
    @unsubscribeFromThreadStore()
    @unsubscribeFromUserSessionStore()

  _renderMessage: (message) ->
    {metadata, data} = message
    <div key={'mm' + metadata.id}>{metadata.AuthorId}: {data.value}</div>

  _renderThreadNamesAndMessages: ->
    elements = []
    for thread, object of @state.threadNames
      if not @state.threadTrees or thread not of @state.threadTrees
        continue
      # Perform a traversal on the tree and print out all the messages
      queue = []
      for node in @state.threadTrees[thread].children
        queue.push node
      while queue.length
        messageNode = queue.shift()

        # If the message isn't loaded yet, don't keep traversing
        if messageNode.id not of @state.messages
          continue
        message = @state.messages[messageNode.id]
        elements.push @_renderMessage message
        for node in messageNode.children
          queue.push node

      elements.push(<div key={thread}>{object.displayName}</div>)

    return elements

  render: ->
    return (
      <div className="mui-app-content-canvas container">
        <div className="page-header">
          <h1>Welcome</h1>
        </div>
        Hello {if @state.user then @state.user.username else "World"}!
        {@_renderThreadNamesAndMessages()}
      </div>
    )

module.exports = Home
