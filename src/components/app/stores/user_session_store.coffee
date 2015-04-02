Reflux = require 'reflux'

{userLoginRequest, userLogoutRequest, addUserSession} = require '../actions'

UserSessionStore = Reflux.createStore
  listenables: [{userLoginRequest}, {userLogoutRequest}, {addUserSession}]
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
    .fail userLoginRequest.failed

  onUserLoginRequestCompleted: (response) ->
    @user = response.user
    @_triggerStateChange()

  onUserLoginRequestFailed: (error) ->
    # Failed to log the user in. Should do a toast or something
    @user = null
    @_triggerStateChange()

  onUserLogoutRequest: ->
    # Make the request to logout
    $.get('/user/logout').done (response) ->
      if response.ok
        userLogoutRequest.completed(response.body)
      else
        userLogoutRequest.failed(response.error)
    .fail userLogoutRequest.failed

  onUserLogoutRequestCompleted: ->
    @user = null
    @_triggerStateChange()

  onUserLogoutRequestFailed: (error) ->
    # TODO: Figure out what to do in this case, nothing perhaps?

  onAddUserSession: (user) ->
    @user = user
    @_triggerStateChange()

  _triggerStateChange: ->
    @trigger @user

  getUser: ->
    return @user

module.exports = UserSessionStore
