Reflux = require 'reflux'

{userLoginRequest, userLogoutRequest} = require '../actions'

exports.UserSessionStore = Reflux.createStore
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

  onUserLoginRequestCompleted: (user) ->
    # TODO: Figure out what to do with the potential redirect here
    console.log 'login success!', user
    @user = user

  onUserLoginRequestFailed: (error) ->
    # Failed to log the user in. Should do a toast or something
    console.log 'login failed!', error
    @user = null

  onUserLogoutRequest: ->
    # Make the request to logout

  onUserLogoutRequestCompleted: ->

  onUserLogoutRequestFailed: (error) ->
