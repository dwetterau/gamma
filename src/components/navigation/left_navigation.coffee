React = require 'react'
{MenuItems, LeftNav} = require 'material-ui'

LeftNavigation = React.createClass
  displayName: "LeftNavigation"

  getMenuItems: ->
    menuItems = [
      {route: '/', text: 'Home'}
    ]
    if @props.user
      menuItems = menuItems.concat [
        {type: MenuItems.SUBHEADER, text: @props.username}
        {route: '/user/password', text: 'Change Password'}
        {route: '/user/logout', text: 'Logout'}
      ]
    else
      menuItems = menuItems.concat [
        {route: '/user/login', text: 'Login'}
        {route: '/user/create', text: 'Create Account'}
      ]

  getSelectedIndex: (menuItems) ->
    for item, index in menuItems
      if item.text == @props.tab
        return index
    return 0

  render: () ->
    menuItems = @getMenuItems()
    selectedIndex = @getSelectedIndex menuItems
    <LeftNav menuItems={menuItems}, header='base-node-app', selectedIndex={selectedIndex} />
