React = require 'react'
{Paper, TextField, RaisedButton} = require 'material-ui'

ChatBox = require './thread/chat_box'

Thread = React.createClass

  getInitialState: ->
    return {
      currentListIndex: 0
    }

  _onSend: (content) ->
    getParentId = (listIndex) =>
      currentMessageList = @props.messageLists[listIndex]
      previousId = currentMessageList[currentMessageList.length - 1]
      return @props.messages[previousId].metadata.ParentId

    if @state.currentListIndex >= @props.messageLists.length
      # We have a new fork. Send a type 1 message first
      # TODO: Let this fork from any branch
      parentId = getParentId 0
      @props.sendMessage(@props.threadId, '', 1, parentId).done (response) =>
        if response.ok
          parentId = response.body.message.id
          @props.sendMessage @props.threadId, content, 0, parentId

    else
      parentId = getParentId @state.currentListIndex
      @props.sendMessage @props.threadId, content, 0, parentId

  _onCurrentListIndexUpdate: ->
    currentListIndex = parseInt @refs.currentListIndexTextField.getValue(), 10
    @setState {currentListIndex}

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
    for messageList in @props.messageLists
      messages.push []
      for messageId in messageList
        # If the message isn't loaded yet, don't keep traversing
        if not @_hasMessage messageId
          break
        messages[messages.length - 1].push @_renderMessage messageId


    if messages.length
      lists = []
      for messageList, index in messages
        lists.push (
          <div key={"li" + index} className="thread-message-list">
            {messageList}
          </div>
        )
      return lists
    else
      return (
        <div className="thread-message-list">
          <div>Thread has no messages!</div>
        </div>
      )

  render: ->
    threadId = @props.threadId
    <div>
      <div className="col-sm-10 thread-message-list-container">
        <Paper>
          {@_renderMessages()}
        </Paper>
      </div>
      <div className="col-sm-2">
        <TextField ref="currentListIndexTextField" defaultValue="0"
          hintText="Current List Index"/>
        <RaisedButton label="Update" onClick={@_onCurrentListIndexUpdate} />
      </div>
      <div className="col-sm-offset-2 col-sm-10 chat-box">
        <ChatBox onSend={@_onSend} />
      </div>
    </div>

module.exports = Thread
