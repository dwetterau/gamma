React = require 'react'
Router = require 'react-router'
RouteHandler = Router.RouteHandler

cursorStore = require '../stores/cursor_store'
messageStore = require '../stores/message_store'
notificationStore = require '../stores/notification_store'
threadStore = require '../stores/thread_store'
userSessionStore = require '../stores/user_session_store'
userStore = require '../stores/user_store'

# Actions this page can make
{loadThreads, loadUsers} = require '../actions'

Home = React.createClass

  mixins: [Router.Navigation]

  getInitialState: ->
    user = userSessionStore.getUser()
    state = {
      threadTrees: {}
      threadNames: threadStore.getThreadNames()
      threadMessageMap: {}
      messages: {}
      cursors: {}
      users: {}
    }
    if user?
      state.user = user

    return state

  _onUserSessionUpdate: (user) ->
    @setState {user}

  _onUserUpdate: (userIds) ->
    users = @state.users
    for userId in userIds
      users[userId] = userStore.getUser(userId)
    @setState {users}

  _onThreadStoreUpdate: (threadIds) ->
    threadTrees = @state.threadTrees
    for threadId in threadIds
      threadTrees[threadId] = threadStore.getTree threadId
    @setState {threadTrees}

  _onCursorStoreUpdate: (threadId) ->
    cursors = @state.cursors
    cursors[threadId] = cursorStore.getCursor(threadId)
    @setState {cursors}

  componentDidMount: ->
    @unsubscribeFromCursorStore = cursorStore.listen(@_onCursorStoreUpdate)
    @unsubscribeFromMessageStore = messageStore.listen(@_onMessageStoreUpdate)
    @unsubscribeFromThreadStore = threadStore.listen(@_onThreadStoreUpdate)
    @unsubscribeFromUserSessionStore = userSessionStore.listen(@_onUserSessionUpdate)
    @unsubscribeFromUserStore = userStore.listen(@_onUserUpdate)

    # Load all threads for the user
    loadThreads()

  componentWillUnmount: ->
    @unsubscribeFromCursorStore()
    @unsubscribeFromMessageStore()
    @unsubscribeFromThreadStore()
    @unsubscribeFromUserSessionStore()

  _addMessageToThread: (messageId, threadId) ->
    if threadId not of @state.threadMessageMap
      @state.threadMessageMap[threadId] = []

    @state.threadMessageMap[threadId].push messageId

  _onMessageStoreUpdate: (messageIds) ->
    messages = @state.messages
    userIds = {}
    for messageId in messageIds
      messages[messageId] = messageStore.getMessage(messageId)
      authorId = messages[messageId].metadata.AuthorId
      if authorId not of @state.users
        userIds[authorId] = true

      @_addMessageToThread messageId, messages[messageId].metadata.ThreadId

    userIdsToLookup = (userId for userId, _ of userIds)
    loadUsers(userIdsToLookup)

    @setState {messages}

  _switchThread: (threadId) ->
    # TODO: Put this in a listener for scrolling of the thread (or better interaction)
    cursorStore.updateCursor(threadId, new Date())
    @transitionTo '/thread/' + threadId

  _getMessagesForThread: (threadId) ->
    if threadId not of @state.threadMessageMap
      return {}

    messages = {}
    for messageId in @state.threadMessageMap[threadId]
      messages[messageId] = @state.messages[messageId]
    return messages

  _renderThreadSidebar: ->
    threads = []
    for threadId of @state.threadNames
      # Determine if the thread has been updated
      updated = false
      if threadId of @state.cursors
        updated = threadStore.hasBeenUpdated(@state.cursors[threadId], threadId)

      className = 'thread-name'
      if updated
        className += ' updated'

      threads.push(
        <div className={className} onClick={@_switchThread.bind(this, threadId)} key={"tn" + threadId}>
          {@state.threadNames[threadId].displayName}
        </div>
      )
    <div className="col-sm-2">
      {threads}
    </div>

  _renderThreadComponent: ->
    threadId = @props.params.threadId
    tree = if threadId of @state.threadTrees then @state.threadTrees[threadId] else null
    if threadId of @state.threadNames
      threadProps = {
        threadId,
        tree,
        users: @state.users,
        messages: @_getMessagesForThread(threadId)
      }
      <RouteHandler {...threadProps}/>
    else
      <div className="col-sm-10">Thread not found!</div>

  render: ->
    return (
      <div className="mui-app-content-canvas container">
        <div className="component">
          {@_renderThreadSidebar()}
          {@_renderThreadComponent()}
        </div>
      </div>
    )

module.exports = Home
