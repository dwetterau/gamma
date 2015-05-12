Reflux = require 'reflux'
{loadUsers} = require '../actions'

UserStore = Reflux.createStore
  listenables: [
    {loadUsers}
  ]
  init: ->
    @data = {}
    @requested = {}

  # Load the messages for the specified thread
  onLoadUsers: (userIds) ->
    # Only request info for userIds we haven't requested yet
    userIds = (id for id in userIds when id not of @requested)

    # If it's an empty list, just return
    if not userIds.length
      return

    # Add the remaining ids to requested
    for id in userIds
      @requested[userIds] = true

    $.get('/api/users', {userIds}, (response) =>
      if response.ok
        users = response.body.users
        updated = []
        for userId, user of users
          @data[userId] = user
          updated.push userId
        @_triggerStateChange(updated)
      else
        # Remove the ids from requested if the request failed
        for id in userIds
          delete @requested[id]
    )

  getUser: (userId) ->
    if userId not of @data
      return null

    return @data[userId]

  _triggerStateChange: (userIds) ->
    @trigger userIds

module.exports = UserStore
