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
    if user?
      return {user}
    return {}

  _onUserSessionUpdate: (user) ->
    @setState {user}

  _onThreadStoreUpdate: (threadIds) ->
    if 'threadNames' not of @state
      threadNames = threadStore.getThreadNames()
      @setState {threadNames}

  _onCursorStoreUpdate: (threadId) ->
    console.log "Got cursor for threadId: ", threadId, cursorStore.getCursor(threadId)

  componentDidMount: ->
    @unsubscribeFromCursorStore = cursorStore.listen(@_onCursorStoreUpdate)
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
    names = []
    messages = []
    for thread, object of @state.threadNames
      messageTree = threadStore.getTree thread
      # Perform a traversal on the tree and print out all the messages
      queue = [messageTree]
      while queue.length and queue[0]
        debugger
        messageNode = queue.shift()
        message = messageStore.getMessage(messageNode.id)
        messages.push @_renderMessage message
        for node in messageNode.children
          queue.push node


      names.push(<div key={thread}>{object.displayName}</div>)
    return names

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
