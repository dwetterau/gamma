React = require 'react'
FormPage = require './form_page'
{userLogoutRequest} = '../../actions'

exports.Logout = React.createClass

  componentDidMount: ->
    userLogoutRequest()
