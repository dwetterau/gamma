React = require 'react'
Router = require 'react-router'

messageStore = require '../stores/message_store'

Thread = React.createClass

  mixins: [Router.State]

  getInitialState: ->
    return {
      messages: {}
    }

  componentDidMount: ->
    @unsubscribeFromMessageStore = messageStore.listen(@_onMessageStoreUpdate)

  componentWillUnmount: ->
    @unsubscribeFromMessageStore()

  _onMessageStoreUpdate: (messageId) ->
    # TODO: Do something smarter here.
    messages = @state.messages
    messages[messageId] = messageStore.getMessage(messageId)
    @setState {messages}


  _renderMessage: (message) ->
    {metadata, data} = message
    <div key={'mm' + metadata.id}>
      {metadata.AuthorId}: {data.value}
    </div>

  _renderMessages: ->
    elements = []
    # Perform a traversal on the tree and print out all the messages
    queue = []
    for node in @props.tree
      queue.push node
    while queue.length
      messageNode = queue.shift()

      # If the message isn't loaded yet, don't keep traversing
      if messageNode.id not of @state.messages
        continue
      message = @state.messages[messageNode.id]
      elements.push @_renderMessage message
      for node in messageNode.children
        queue.push node

    return elements

  render: ->
    threadId = @props.threadId
    <div>
      Thread Page id={threadId}
      {@_renderMessages()}
    </div>

module.exports = Thread
