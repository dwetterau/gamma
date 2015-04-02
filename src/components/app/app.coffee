App = ->
  React = require 'react'
  Router = require 'react-router'
  AppRoutes = require './app_routes'
  injectTapEventPlugin = require 'react-tap-event-plugin'
  Actions = require './actions'

  # For React Developer Tools
  window.React = React

  # Will go away with react 1.0 release
  injectTapEventPlugin()

  # Read the props from the server and fire appropriate actions for them
  _processProps(Actions)

  Router.create(
    routes: AppRoutes
    location: Router.HistoryLocation
    scrollBehavior: Router.ScrollToTopBehavior
  ).run (Handler) ->
    # This is called whenever the URL is changed.
    # Handler is the ReactComponent class that will be rendered
    React.render React.createElement(Handler), document.body

_processProps = (Actions) ->
  propsFromServer = JSON.parse($('#react_app_props').html())

  # For each field the server gives, fire the right action for it
  if 'user' of propsFromServer
    Actions.addUserSession propsFromServer.user

module.exports = App
