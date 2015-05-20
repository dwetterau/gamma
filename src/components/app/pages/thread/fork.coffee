React = require 'react'
{Paper} = require 'material-ui'

Fork = React.createClass

  getInitialState: ->
    return {
      scrollFixed: true
    }

  _scrollToBottom: ->
    node = @getDOMNode()
    node.scrollTop = node.scrollHeight

  _saveScroll: ->
    node = @getDOMNode()
    @scrollHeight = node.scrollHeight;
    @scrollTop = node.scrollTop

  _scrollToSaved: ->
    node = @getDOMNode()
    node.scrollTop = @scrollTop + (node.scrollHeight - @scrollHeight)

  _onScroll: (e) ->
    node = @getDOMNode()
    scrollFixed = node.scrollTop == @scrollTop
    if scrollFixed != @state.scrollFixed
      @setState {scrollFixed}

  _selectFork: (e) ->
    @props.updateCurrentListIndex(@props.index)

  componentDidUpdate: ->
    # If we are in "fixed" mode, make sure we are still scrolled down
    if @state.scrollFixed
      @_scrollToBottom()
    else
      @_scrollToSaved()

  componentWillUpdate: ->
    @_saveScroll()

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
    className = "fork-container"
    if @props.isSelected
      className += " active-fork"

    <div className={className}>
      <Paper>
        <div className="fork-messages" onScroll={@_onScroll}>
          {@_renderMessages()}
        </div>
      </Paper>
      {
        if @props.isSelected
          (<div className="active-fork-text">
            Active Fork
          </div>)
        else
          (<div className="inactive-fork-text" onClick={@_selectFork}>
            Select as Active Fork
          </div>)
      }
    </div>

module.exports = Fork
