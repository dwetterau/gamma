React = require 'react'
userSessionStore = require '../stores/user_session_store'
notificationStore = require '../stores/notification_store'
messageStore = require '../stores/message_store'
threadStore = require '../stores/thread_store'

Home = React.createClass
  getInitialState: ->
    user = userSessionStore.getUser()
    if user?
      return {user}
    return {}

  _onUserSessionUpdate: (user) ->
    @setState {user}

  _onMessageStoreUpdate: (messageId) ->
    console.log messageStore.getMessage(messageId)

  _onThreadStoreUpdate: (threadId) ->
    console.log threadStore.getTree(threadId)

  componentDidMount: ->
    @unsubscribeFromUserSessionStore = userSessionStore.listen(@_onUserSessionUpdate)
    @unsubscribeFromMessageStore = messageStore.listen(@_onMessageStoreUpdate)
    @unsubscribeFromThreadStore = threadStore.listen(@_onThreadStoreUpdate)

  componentWillUnmount: ->
    @unsubscribeFromUserSessionStore()
    @unsubscribeFromMessageStore()

  render: ->
    return (
      <div className="mui-app-content-canvas container">
        <div className="page-header">
          <h1>Welcome</h1>
        </div>
        Hello {if @state.user then @state.user.username else "World"}!
      </div>
    )

module.exports = Home
