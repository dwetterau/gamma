React = require 'react'
{Paper, RaisedButton, TextField} = require 'material-ui'

ChatBox = React.createClass

  _onSend: (e) ->
    @props.onSend @refs.textField.getValue()
    @refs.textField.clearValue()

  render: ->
    <Paper>
      <div className="chat-box-row">
        <div className="chat-box-text-field">
          <TextField ref="textField" multiLine=true />
        </div>
        <div className="chat-box-send-button">
        <RaisedButton label="Send" onClick={@_onSend} />
        </div>
      </div>
    </Paper>

module.exports = ChatBox