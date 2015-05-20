React = require 'react'
{TextField, RaisedButton} = require 'material-ui'

ChatBox = require './thread/chat_box'
Fork = require './thread/fork'

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

  _onCurrentListIndexUpdate: (index) ->
    @setState {currentListIndex: index}

  # Return if we have the message
  _hasMessage: (messageId) ->
    return messageId of @props.messages


  _renderForks: ->
    forks = []
    for messageList, index in @props.messageLists
      isSelected = index == @state.currentListIndex
      forkProps = {
        messages: @props.messages
        users: @props.users
        messageList
        isSelected
        index
        updateCurrentListIndex: @_onCurrentListIndexUpdate
      }
      forks.push (
        <Fork key={"fid" + index} {...forkProps}/>
      )
    return forks

  render: ->
    threadId = @props.threadId
    <div>
      <div className="col-sm-10 thread-message-list-container">
        {@_renderForks()}
      </div>
      <div className="col-sm-offset-2 col-sm-10 chat-box">
        <ChatBox onSend={@_onSend} />
      </div>
    </div>

module.exports = Thread
