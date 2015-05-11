React = require 'react'
{Paper} = require 'material-ui'

Thread = React.createClass

  # Return if we have the message
  _hasMessage: (messageId) ->
    return messageId of @props.messages

  _renderMessage: (messageId) ->
    {metadata, data} = @props.messages[messageId]
    username = "Unknown"
    if metadata.AuthorId of @props.users
      username = @props.users[metadata.AuthorId].username

    <div key={'mm' + metadata.id}>
      {username}<span>: </span>{data.value}
    </div>

  _renderMessages: ->
    messages = []
    for messageList in @props.messageLists
      for messageId in messageList
        # If the message isn't loaded yet, don't keep traversing
        if not @_hasMessage messageId
          break
        messages.push @_renderMessage messageId

    if messages.length
      return messages
    else return (
      <div>Thread has no messages!</div>
    )

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
