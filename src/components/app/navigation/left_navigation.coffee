React = require 'react'
Router = require 'react-router'
{MenuItem, LeftNav} = require 'material-ui'
userSessionStore = require '../stores/user_session_store'
{userLogoutRequest} = require '../actions'
Notifier = require '../utils/notifier'

LeftNavigation = React.createClass

  mixins: [Router.Navigation, Router.State]

  getInitialState: ->
    return {}

  onUserSessionUpdate: (user) ->
    @setState {user}

  componentDidMount: ->
    @unsubscribeFromUserSessionStore = userSessionStore.listen(@onUserSessionUpdate)

  componentWillUnmount: ->
    @unsubscribeFromUserSessionStore()

  getItem: (link, text) ->
    return {
      route: link
      text
    }

  getMenuItems: ->
    menuItems = [
      @getItem 'home', 'Home'
    ]
    if @state.user
      menuItems = menuItems.concat [
        {type: MenuItem.Types.SUBHEADER, text: @state.user.username}
        @getItem 'user/password', 'Change Password'
        {text: 'Logout'}
      ]
    else
      menuItems = menuItems.concat [
        @getItem 'user/login', 'Login'
        @getItem 'user/create', 'Create Account'
      ]

  getSelectedIndex: (menuItems) ->
    for item, index in menuItems
      if item.route and @isActive item.route
        return index
    return 0

  _onLogoutClick: ->
    userLogoutRequest().then (response) =>
      @transitionTo response.redirect_url
      Notifier.info 'Logout successful.'

    .catch Notifier.error

  _onLeftNavChange: (e, key, payload) ->
    if payload.text == 'Logout'
      @_onLogoutClick()
    else
      @transitionTo payload.route

  _onHeaderClick: ->
    @transitionTo 'root'
    @refs.leftNav.close()

  toggle: ->
    @refs.leftNav.toggle()

  _getHeader: ->
    <div className="logo" onClick={@_onHeaderClick}>base-node-app</div>

  render: ->
    menuItems = @getMenuItems()
    selectedIndex = @getSelectedIndex menuItems
    <LeftNav
      menuItems={menuItems}
      selectedIndex={selectedIndex}
      ref="leftNav"
      docked={false}
      isInitiallyOpen={false}
      header={@getHeader}
      onChange={@_onLeftNavChange}/>

module.exports = LeftNavigation
