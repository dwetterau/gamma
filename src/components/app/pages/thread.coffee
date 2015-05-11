React = require 'react'
{Paper} = require 'material-ui'

ChatBox = require './thread/chat_box'

Thread = React.createClass

  getInitialState: ->
    return {
      currentList: 0
    }

  _onSend: (content) ->
    currentMessageList = @props.messageLists[@state.currentList]
    previousId = currentMessageList[currentMessageList.length - 1]
    parentId = @props.messages[previousId].metadata.ParentId
    @props.sendMessage @props.threadId, content, 0, parentId

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
    <div>
      <div className="col-sm-10 thread-message-list-container">
        <Paper>
          <div className="thread-message-list">
            {@_renderMessages()}
          </div>
        </Paper>
      </div>
      <div className="col-sm-10 chat-box">
        <ChatBox onSend={@_onSend} />
      </div>
    </div>

module.exports = Thread
