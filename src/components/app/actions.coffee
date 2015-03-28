Reflux = require 'reflux'

# User session actions
exports.userLoginRequest = Reflux.createAction({asyncResult: true})
exports.userLogoutRequest = Reflux.createAction({asyncResult: true})