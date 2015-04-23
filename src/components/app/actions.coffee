Reflux = require 'reflux'

# User session actions started by the user
exports.userLoginRequest = Reflux.createAction({asyncResult: true})
exports.userLogoutRequest = Reflux.createAction({asyncResult: true})
exports.userCreateRequest = Reflux.createAction({asyncResult: true})

# Used to populate the session store with the user returned by the server
exports.addUserSession = Reflux.createAction()

# Used to add a new message
exports.newMessage = Reflux.createAction()
