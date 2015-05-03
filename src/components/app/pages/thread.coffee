React = require 'react'

messageStore = require '../stores/message_store'

Thread = React.createClass

  getInitialState: ->
    return {
      messages: {}
    }

  componentDidMount: ->
    @unsubscribeFromMessageStore = messageStore.listen(@_onMessageStoreUpdate)

    # Load all messages that we need from the messageStore
    messages = messageStore.getMessagesForThread @props.threadId
    @setState {messages}

  componentWillUnmount: ->
    @unsubscribeFromMessageStore()

  _onMessageStoreUpdate: (messageId) ->
    # TODO: Do something smarter here.
    messages = @state.messages
    messages[messageId] = messageStore.getMessage(messageId)
    @setState {messages}

  # Return if we have the message
  _hasMessage: (messageId) ->
    return messageId of @state.messages

  _renderMessage: (messageId) ->
    {metadata, data} = @state.messages[messageId]
    <div key={'mm' + metadata.id}>
      {metadata.AuthorId}: {data.value}
    </div>

  _renderMessages: ->
    elements = []
    # Perform a traversal on the tree and print out all the messages
    queue = (node for node in @props.tree.children)
    while queue.length
      messageNode = queue.shift()

      # If the message isn't loaded yet, don't keep traversing
      if not @_hasMessage messageNode.id
        continue
      elements.push @_renderMessage messageNode.id
      for node in messageNode.children
        queue.push node

    return elements

  render: ->
    threadId = @props.threadId
    <div className="col-sm-10">
      Thread Page id={threadId}
      {@_renderMessages()}
    </div>

module.exports = Thread
