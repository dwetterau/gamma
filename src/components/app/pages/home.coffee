React = require 'react'
Router = require 'react-router'
RouteHandler = Router.RouteHandler

cursorStore = require '../stores/cursor_store'
messageStore = require '../stores/message_store'
notificationStore = require '../stores/notification_store'
threadStore = require '../stores/thread_store'
userSessionStore = require '../stores/user_session_store'

# Actions this page can make
{loadThreads} = require '../actions'

Home = React.createClass

  mixins: [Router.Navigation]

  getInitialState: ->
    user = userSessionStore.getUser()
    state = {
      threadTrees: {}
      threadNames: threadStore.getThreadNames()
      threadMessageMap: {}
      messages: {}
    }
    if user?
      state.user = user

    return state

  _onUserSessionUpdate: (user) ->
    @setState {user}

  _onThreadStoreUpdate: (threadIds) ->
    threadTrees = @state.threadTrees
    for threadId in threadIds
      threadTrees[threadId] = threadStore.getTree threadId
    @setState {threadTrees}

  _onCursorStoreUpdate: (threadId) ->
    console.log "Got cursor for threadId: ", threadId, cursorStore.getCursor(threadId)


  componentDidMount: ->
    @unsubscribeFromCursorStore = cursorStore.listen(@_onCursorStoreUpdate)
    @unsubscribeFromMessageStore = messageStore.listen(@_onMessageStoreUpdate)
    @unsubscribeFromThreadStore = threadStore.listen(@_onThreadStoreUpdate)
    @unsubscribeFromUserSessionStore = userSessionStore.listen(@_onUserSessionUpdate)

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

  _onMessageStoreUpdate: (messageId) ->
    # TODO: Do something smarter here.
    messages = @state.messages
    messages[messageId] = messageStore.getMessage(messageId)
    @_addMessageToThread messageId, messages[messageId].metadata.ThreadId
    @setState {messages}

  _switchThread: (threadId) ->
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
      threads.push(
        <div onClick={@_switchThread.bind(this, threadId)} key={"tn" + threadId}>
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
