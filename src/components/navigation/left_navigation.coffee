React = require 'react'
{MenuItem, LeftNav} = require 'material-ui'

LeftNavigation = React.createClass
  displayName: "LeftNavigation"

  getItem: (link, text) ->
    return {
      route: link
      text
    }

  getMenuItems: ->
    menuItems = [
      @getItem '/', 'Home'
    ]
    if @props.user
      menuItems = menuItems.concat [
        {type: MenuItem.Types.SUBHEADER, text: @props.user.username}
        @getItem 'user/password', 'Change Password'
        @getItem 'user/logout', 'Logout'
      ]
    else
      menuItems = menuItems.concat [
        @getItem 'user/login', 'Login'
        @getItem 'user/create', 'Create Account'
      ]

  getSelectedIndex: (menuItems) ->
    console.log menuItems
    for item, index in menuItems
      console.log @props.tab
      console.log item.text
      console.log index
      if item.text == @props.tab
        return index
    return 0

  render: () ->
    menuItems = @getMenuItems()
    selectedIndex = @getSelectedIndex menuItems
    console.log selectedIndex
    <LeftNav menuItems={menuItems} selectedIndex={selectedIndex} />

module.exports = LeftNavigation
