React = require 'react'
{Paper, RaisedButton, TextField} = require 'material-ui'

ChatBox = React.createClass

  _onSend: () ->
    @props.onSend @refs.textField.getValue()
    @refs.textField.clearValue()

  _onKeyDown: (e) ->
    if e.which == 13
      e.preventDefault()
      e.stopPropagation()
      @_onSend()
      return false

  render: ->
    <Paper>
      <div className="chat-box-row">
        <div className="chat-box-text-field">
          <TextField ref="textField" multiLine=true onKeyDown={@_onKeyDown}/>
        </div>
        <div className="chat-box-send-button">
        <RaisedButton label="Send" onClick={@_onSend} />
        </div>
      </div>
    </Paper>

module.exports = ChatBox