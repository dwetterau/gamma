React = require 'react'
Router = require 'react-router'
RouteHandler = Router.RouteHandler
{AppBar, AppCanvas} = require 'material-ui'
LeftNavigation = require './navigation/left_navigation'

Layout = React.createClass
  mixins: [Router.State]

  _onMenuIconButtonTouchTap: ->
    @refs.leftNavigation.toggle()

  render: ->
    # TODO: Set the title of the page dynamically with the state mixin
    title = 'Gamma'

    return (
      <div className="site">
        <AppCanvas className="site-content" predefinedLayout={1}>
          <AppBar
            className="mui-dark-theme"
            onMenuIconButtonTouchTap={@_onMenuIconButtonTouchTap}
            title={title}
            zDepth={0} />

          <LeftNavigation ref="leftNavigation" />

          <RouteHandler {...@props}/>


        </AppCanvas>
        <div className="footer mui-dark-theme">
          <div className="container text-center">
            <p className="pull-left">Made By David Wetterau</p>
            <ul className="pull-right list-inline">
              <li><a href="https://github.com/dwetterau/gamma">Github Project</a></li>
              <li><a href="https://github.com/dwetterau/gamma/issues">Issues</a></li>
            </ul>
          </div>
        </div>
      </div>
    )

module.exports = Layout
