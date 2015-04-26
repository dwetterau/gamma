class MessageNode
  constructor: (@id, @parentId) ->
    if not @id
      @id = -1
      @parentId = -1
    @parent = null
    @children = []

  addChild: (childNode) ->
    childNode.setParent this
    @children.push childNode

  removeChild: (childNode) ->
    index = -1
    for child, i in @children
      if child.id == childNode.id
        index = i
        break

    if index != -1
      childNode.setParent null
      @children.splice index

  setParent: (parentNode) ->
    @parent = parentNode

  # Insert the specified node as the new parent
  setNewParent: (newParentNode) ->
    oldParent = @parent
    oldParent.removeChild this
    newParentNode.addChild this
    oldParent.addChild newParentNode

module.exports = MessageNode
