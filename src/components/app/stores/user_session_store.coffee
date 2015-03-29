Reflux = require 'reflux'

{userLoginRequest, userLogoutRequest} = require '../actions'

UserSessionStore = Reflux.createStore
  listenables: [{userLoginRequest}, {userLogoutRequest}]
  init: ->
    # Set up the initial store
    @user = null

  onUserLoginRequest: (fields) ->
    # Make the login request, on the success update the stuff
    $.post('/user/login', fields).done (response) ->
      if response.ok
        userLoginRequest.completed(response.body)
      else
        userLoginRequest.failed(response.error)
    .fail (error) ->
      userLoginRequest.failed(error)

  onUserLoginRequestCompleted: (response) ->
    # TODO: Figure out what to do with the potential redirect here
    @user = response.user
    @_triggerStateChange()

  onUserLoginRequestFailed: (error) ->
    # Failed to log the user in. Should do a toast or something
    @user = null
    @_triggerStateChange()

  onUserLogoutRequest: ->
    # Make the request to logout

  onUserLogoutRequestCompleted: ->

  onUserLogoutRequestFailed: (error) ->

  _triggerStateChange: ->
    @trigger @user

module.exports = UserSessionStore
