Reflux = require 'reflux'
{loadUsers} = require '../actions'

UserStore = Reflux.createStore
  listenables: [
    {loadUsers}
  ]
  init: ->
    @data = {}

  # Load the messages for the specified thread
  onLoadUsers: (userIds) ->
    # If it's an empty list, just return
    if not userIds.length
      return

    $.get('/api/users', {userIds}, (response) =>
      if response.ok
        users = response.body.users
        updated = []
        for userId, user of users
          @data[userId] = user
          updated.push userId
        @_triggerStateChange(updated)
    )

  getUser: (userId) ->
    if userId not of @data
      return null

    return @data[userId]

  _triggerStateChange: (userIds) ->
    @trigger userIds

module.exports = UserStore
