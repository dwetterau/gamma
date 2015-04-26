React = require 'react'
FormPage = require './form_page'
Notifier = require '../../lib/notifier'

ChangePassword = React.createClass

  _onSubmit: (fields) ->
    $.post('/api/user/password', fields).done (response) =>
      if response.ok
        Notifier.info 'Password changed!'
        @_clearFields fields
      else
        Notifier.error response.error

    .fail Notifier.error

  _clearFields: ->
    @refs.FormPage.clearValues()

  render: () ->
    React.createElement FormPage,
      ref: 'FormPage'
      pageHeader: 'Change Password'
      action: '/user/password'
      inputs: [
        {
          type: "password"
          id: "old_password"
          floatingLabelText: "Old Password"
        }, {
          type: "password"
          id: "new_password"
          floatingLabelText: "New Password"
        }, {
          type: "password"
          id: "confirm_password"
          floatingLabelText: "Confirm Password"
        }
      ]
      submitLabel: 'Change password'
      onSubmit: @_onSubmit

module.exports = ChangePassword
