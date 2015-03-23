React = require 'react'
{MenuItem, LeftNav} = require 'material-ui'

LeftNavigation = React.createClass
  displayName: "LeftNavigation"

  getItem: (link, text) ->
    return {
      type: MenuItem.Types.LINK,
      payload: link
      text
    }

  getMenuItems: ->
    menuItems = [
      {route: '/', text: 'Home'}
    ]
    if @props.user
      menuItems = menuItems.concat [
        {type: MenuItem.SUBHEADER, text: @props.user.username}
        @getItem '/user/password', 'Change Password'
        @getItem '/user/logout', 'Logout'
      ]
    else
      menuItems = menuItems.concat [
        @getItem '/user/login', 'Login'
        @getItem '/user/create', 'Create Account'
      ]

  getSelectedIndex: (menuItems) ->
    for item, index in menuItems
      if item.text == @props.tab
        return index
    return 0

  render: () ->
    menuItems = @getMenuItems()
    selectedIndex = @getSelectedIndex menuItems
    <LeftNav menuItems={menuItems}, selectedIndex={selectedIndex} />

module.exports = {LeftNavigation}
