React = require 'react'
Router = require 'react-router'
RouteHandler = Router.RouteHandler
{AppBar, AppCanvas} = require 'material-ui'
LeftNavigation = '../navigation/left_navigation'

Master = React.createClass
  contextTypes: {
    router: React.PropTypes.func
  }

  _onMenuIconButtonTouchTap: ->
    @refs.leftNavigation.toggle()

  render: ->
    # TODO: Set the title of the page dynamically
    title = 'base-node-app'

    return (
      <AppCanvas predefinedLayout="1">
        <AppBar
          className="mui-dark-theme"
          onMenuIconButtonTouchTap={@_onMenuIconButtonTouchTap}
          title={title}
          zDepth={0} />

        <LeftNavigation ref="leftNavigation" />

        <RouteHandler />

        <footer>
          <div className="container text-center">
            <p className="pull-left">Made By David Wetterau</p>
            <ul className="pull-right list-inline">
              <li><a href="https://github.com/dwetterau/base-node-app">Github Project</a></li>
              <li><a href="https://github.com/dwetterau/base-node-app/issues">Issues</a></li>
            </ul>
          </div>
        </footer>

      </AppCanvas>
    )