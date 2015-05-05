React = require 'react'
{Paper} = require 'material-ui'

Thread = React.createClass

  # Return if we have the message
  _hasMessage: (messageId) ->
    return messageId of @props.messages

  _renderMessage: (messageId) ->
    {metadata, data} = @props.messages[messageId]
    <div key={'mm' + metadata.id}>
      {metadata.AuthorId}: {data.value}
    </div>

  _renderMessages: ->
    messages = []
    # Perform a traversal on the tree and print out all the messages
    if not @props.tree
      return (
        <div>Thread has no messages!</div>
      )
    queue = (node for node in @props.tree.children)
    while queue.length
      messageNode = queue.shift()

      # If the message isn't loaded yet, don't keep traversing
      if not @_hasMessage messageNode.id
        continue
      messages.push @_renderMessage messageNode.id
      for node in messageNode.children
        queue.push node

    # Reverse the message order. This is needed because we're using flexbox
    return messages

  render: ->
    threadId = @props.threadId
    <div className="col-sm-10 thread-message-list-container">
      <Paper>
        <div className="thread-message-list">
          {@_renderMessages()}
        </div>
      </Paper>
    </div>

module.exports = Thread
