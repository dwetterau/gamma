App = ->
  React = require 'react'
  Router = require 'react-router'
  AppRoutes = require './app_routes'
  injectTapEventPlugin = require 'react-tap-event-plugin'

  # For React Developer Tools
  window.React = React

  # Will go away with react 1.0 release
  injectTapEventPlugin()

  Router.create(
    routes: AppRoutes
    scrollBehavior: Router.ScrollToTopBehavior
  ).run (Handler) ->
    # This is called whenever the URL is changed.
    # Handler is the ReactComponent class that will be rendered
    React.render React.createElement(Handler), document.body

module.exports = App
