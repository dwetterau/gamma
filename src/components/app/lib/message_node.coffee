class MessageNode
  constructor: (@id, @parentId) ->
    if not @id
      @id = -1
      @parentId = -1
    @children = []

  addChild: (childNode) ->
    @children.push childNode

module.exports = MessageNode
