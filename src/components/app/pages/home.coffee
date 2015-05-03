React = require 'react'
Router = require 'react-router'
RouteHandler = Router.RouteHandler

cursorStore = require '../stores/cursor_store'
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

  _switchThread: (threadId) ->
    @transitionTo '/thread/' + threadId

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
    if threadId of @state.threadTrees
      threadProps = {
        threadId,
        tree: @state.threadTrees[threadId]
      }
      <RouteHandler {...threadProps}/>
    else
      <div className="col-sm-10">Thread not found!</div>

  render: ->
    return (
      <div className="mui-app-content-canvas container">
        <div className="page-header">
          <h1>Welcome</h1>
        </div>
        <div className="component">
          {@_renderThreadSidebar()}
          {@_renderThreadComponent()}
        </div>
      </div>
    )

module.exports = Home
