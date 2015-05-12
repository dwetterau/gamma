class MessageNode
  constructor: (@id, @parentId, @previousId) ->
    if not @id
      @id = -1
      @parentId = -1
      @previousId = -1
    @parent = null
    @children = []

  addChild: (childNode) ->
    childNode.setParent this

    # Add the child in the proper place in the sorted children array.
    # Optimize for the common append case.
    # TODO: Use a binary search to find the location.
    insertIndex = 0;
    if @children.length == 0
      @children.push childNode
      return

    for i in [@children.length - 1..0]
      if @children[i].id < childNode.id
        insertIndex = i + 1
        break

    if insertIndex == @children.length
      @children.push childNode
    else
      @children.splice insertIndex, 0, childNode

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
