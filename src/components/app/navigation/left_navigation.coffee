React = require 'react'
Router = require 'react-router'
{MenuItem, LeftNav} = require 'material-ui'

LeftNavigation = React.createClass

  mixins: [Router.Navigation, Router.State]

  getItem: (link, text, onClick) ->
    return {
      route: link
      text
      onClick
    }

  getMenuItems: ->
    menuItems = [
      @getItem 'home', 'Home'
    ]
    if @props.user
      menuItems = menuItems.concat [
        {type: MenuItem.Types.SUBHEADER, text: @props.user.username}
        @getItem 'user/password', 'Change Password'
        @getItem null, 'Logout', @_onLogoutClick
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
    return null

  _onLogoutClick: ->
    $.get('/user/logout')

  _onLeftNavChange: (e, key, payload) ->
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
    console.log selectedIndex
    <LeftNav
      menuItems={menuItems}
      selectedIndex={selectedIndex}
      ref="leftNav"
      docked={false}
      isInitiallyOpen={false}
      header={@getHeader}
      onChange={@_onLeftNavChange}/>

module.exports = LeftNavigation
