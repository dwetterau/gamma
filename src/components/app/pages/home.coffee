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

  _activeValidThread: ->
    threadId = @props.params.threadId
    if threadId of @state.threadNames
      return threadId
    else
      return null

  # Given the thread tree, generate a list of message lists to render
  _getMessageLists: (threadId) ->
    if threadId not of @state.threadTrees or not @state.threadTrees[threadId]
      return []
    messageLists = []
    queue = [@state.threadTrees[threadId]]
    parentToIndex = {}
    combine = false
    while queue.length
      node = queue.shift()

      # Maintain the causal dependencies, don't traverse nodes we can't reach yet
      if node.previousId != -1 and (node.previousId not of @state.messages)
        continue

      # Don't actually add the sentinel node to render.
      if node.id != -1
        index = 0

        # Recognize the case where we need to collapse the first two lists
        if node.parentId == -1
          combine = true

        if node.parentId of parentToIndex
          index = parentToIndex[node.parentId]
        messageLists[index].push node.id

      if node.children.length
        messageLists.push []
        parentToIndex[node.id] = messageLists.length - 1

      for child in node.children
        queue.push child

    # We need to combine the first two lists here for easier rendering
    # They are separate because the first sent message in a thread has a
    # parentId of -1 and all others have it correctly set.
    if messageLists.length > 1 and combine
      firstList = messageLists.shift()
      messageLists[0] = firstList.concat messageLists[0]

    return messageLists

  sendMessage: (threadId, content, type, parentId) ->
    messageStore.sendNewMessage threadId, content, type, parentId

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
    threadId = @_activeValidThread()
    tree = if threadId of @state.threadTrees then @state.threadTrees[threadId] else null
    if threadId
      threadProps = {
        threadId,
        tree,
        users: @state.users,
        messages: @_getMessagesForThread(threadId)
        messageLists: @_getMessageLists(threadId)
        sendMessage: @sendMessage
      }
      <RouteHandler {...threadProps}/>
    else
      <div className="col-sm-10">
        Thread not found!
      </div>

  _renderLoggedInUserComponent: ->
    user = userSessionStore.getUser()
    username = if user then user.username else "Unknown User"
    id = if user then user.id else -1
    <div className="col-sm-2">
      <div>{username}</div>
      <div>id = {id}</div>
    </div>

  render: ->
    return (
      <div className="mui-app-content-canvas container thread-view-page">
        <div className="component">
          {@_renderThreadSidebar()}
          {@_renderThreadComponent()}
          {@_renderLoggedInUserComponent()}
        </div>
      </div>
    )

module.exports = Home
