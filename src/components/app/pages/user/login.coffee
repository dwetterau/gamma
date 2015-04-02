React = require 'react'
Router = require 'react-router'
FormPage = require './form_page'
{userLoginRequest} = require '../../actions'
Notifier = require '../../utils/notifier'

Login = React.createClass

  mixins: [Router.Navigation]

  _onSubmit: (fields) ->
    userLoginRequest(fields).then (response) =>
      @transitionTo response.redirect_url
      Notifier.info('Login successful!');

    .catch Notifier.error

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
