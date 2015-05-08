Reflux = require 'reflux'

# User session actions started by the user
exports.userLoginRequest = Reflux.createAction({asyncResult: true})
exports.userLogoutRequest = Reflux.createAction({asyncResult: true})
exports.userCreateRequest = Reflux.createAction({asyncResult: true})

# Used to populate the session store with the user returned by the server
exports.addUserSession = Reflux.createAction()

# Used to add a new message
exports.newMessage = Reflux.createAction()

# Used to add a new thread to the mapping
exports.newThread = Reflux.createAction()

# Used to tell the thread store to load all threads for a user
exports.loadThreads = Reflux.createAction()

# Used to load all existing messages for a thread
exports.loadThreadMessages = Reflux.createAction()

# Used to load many messages at once into the message and thread stores
exports.bulkLoadMessages = Reflux.createAction()

# Used to load the cursor for a thread
exports.loadThreadCursor = Reflux.createAction()

# Used to load users needed for displaying
exports.loadUsers = Reflux.createAction()
