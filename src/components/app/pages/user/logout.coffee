React = require 'react'
Router = require 'react-router'
FormPage = require './form_page'
{userLogoutRequest} = require '../../actions'

Logout = React.createClass

  mixins: [Router.Navigation]

  componentDidMount: ->
    userLogoutRequest().then ->
      @transitionTo "/"
    .catch (err) ->
      # TODO: Toast this
      console.log "failed to logout"

  render: ->
    # Nothing to do here, I could redirect on render to '/' or something?
    <div>logged out!</div>

module.exports = Logout
