React = require 'react'

Fork = React.createClass

  # Return if we have the message
  _hasMessage: (messageId) ->
    return messageId of @props.messages

  _renderMessage: (messageId) ->
    {metadata, data} = @props.messages[messageId]
    # Don't render fork messages
    if metadata.type != 0
      return ''

    username = "Unknown"
    if metadata.AuthorId of @props.users
      username = @props.users[metadata.AuthorId].username

    <div key={'mm' + metadata.id}>
      {username}<span>: </span>{data.value}
    </div>

  _renderMessages: ->
    messages = []
    for messageId in @props.messageList
      if @_hasMessage messageId
        messages.push @_renderMessage messageId
      else
        # These messages are casually ordered, don't render
        # them out of order.
        break

    if not messages.length
      <div>Thread has no messages!</div>
    else
      return messages

  render: ->
    <div className="fork-messages">
      {@_renderMessages()}
    </div>

module.exports = Fork
