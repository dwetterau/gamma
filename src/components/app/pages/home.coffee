React = require 'react'
userSessionStore = require '../stores/user_session_store'
notificationStore = require '../stores/notification_store'

Home = React.createClass
  getInitialState: ->
    user = userSessionStore.getUser()
    if user?
      return {user}
    return {}

  onUserSessionUpdate: (user) ->
    @setState {user}

  componentDidMount: ->
    @unsubscribeFromUserSessionStore = userSessionStore.listen(@onUserSessionUpdate)

  componentWillUnmount: ->
    @unsubscribeFromUserSessionStore()

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
