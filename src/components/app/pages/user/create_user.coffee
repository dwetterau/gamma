React = require 'react'
Router = require 'react-router'
FormPage = require './form_page'
{createUserRequest} = require '../../actions'
Notifier = require '../../utils/notifier'

CreateUser = React.createClass

  mixins: [Router.Navigation]

  _onSubmit: (fields) ->
    createUserRequest(fields).then (response) =>
      @transitionTo response.redirect_url
      Notifier.info 'Account created!'

    .catch Notifier.error

  render: () ->
    React.createElement FormPage,
      pageHeader: 'Create an account'
      action: '/user/create'
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
          type: "password"
          name: "confirm_password"
          key: "confirm_password"
          id: "confirm_password"
          floatingLabelText: "Confirm Password"
        }
      ]
      submitLabel: 'Create account'

module.exports = CreateUser
