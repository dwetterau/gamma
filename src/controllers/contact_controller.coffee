{Contact, Group, User} = require '../models'

exports.post_create_group = (req, res) ->
  req.assert('name', 'Group name is not valid.').notEmpty()
  fail = (errors) ->
    console.log errors
    res.send {ok: false, error: errors}

  errors = req.validationErrors()
  if errors?
    return fail errors

  initialContactIds = req.param 'contactIds'
  if not initialContactIds?
    initialContactIds = []
  groupName = req.param 'name'
  newGroup = null
  contacts = null

  # Add req.user's contact to list of members if not in it already
  # Look up the contact first
  Contact.find({where: {UserId: req.user.id}}).then (contact) ->
    includedSelf = false
    for contactId in initialContactIds
      if contact.id == contactId
        includedSelf = true
        break

    if not includedSelf
      initialContactIds.push contact.id

    return Contact.findAll(initialContactIds)
  .then (allContacts) ->
    if allContacts.length != initialContactIds.length
      throw "Invalid contact id specified."

    contacts = allContacts
    return Group.create(displayName: groupName)
  .then (group) ->
    newGroup = group
    return group.setContacts contacts
  .then ->
    res.send {ok: true, body: {group: newGroup}}
  .catch fail
