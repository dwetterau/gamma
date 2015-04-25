React = require 'react'
Router = require 'react-router'
FormPage = require './form_page'
{userLoginRequest} = require '../../actions'
Notifier = require '../../lib/notifier'

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
          id: "username"
          floatingLabelText: "Username"
        }, {
          type: "password"
          id: "password"
          floatingLabelText: "Password"
        }, {
          type: "hidden"
          id: "redirect"
          value: @props.redirect || ""
        }
      ]
      submitLabel: 'Login'
      onSubmit: @_onSubmit

module.exports = Login
