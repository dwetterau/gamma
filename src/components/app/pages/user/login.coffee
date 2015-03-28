React = require 'react'
FormPage = require './form_page'
{userLoginRequest} = require '../../actions'

Login = React.createClass

  _onSubmit: (fields) ->
    userLoginRequest(fields)

  render: () ->
    React.createElement FormPage,
      pageHeader: 'Sign in'
      inputs: [
        {
          type: "text"
          name: "username"
          key: "username"
          id: "username"
          floatingLabelText: "Username"
          autofocus: ""
        }, {
          type: "password"
          name: "password"
          key: "password"
          id: "password"
          floatingLabelText: "Password"
        }, {
          type: "hidden"
          name: "redirect"
          key: "redirect"
          id: "redirect"
          value: @props.redirect
        }
      ]
      submitLabel: 'Login'
      onSubmit: @_onSubmit

module.exports = Login
