React = require 'react'

# This dependency will be removed in react v1.0
injectTapEventPlugin = require 'react-tap-event-plugin'
{Paper, RaisedButton, TextField} = require 'material-ui'

###
  Expected props:
  - pageHeader: The header of the page
  - action: The action url for the form
  - inputs: an array of inputObjects
  - submitLabel: the label for the submit button
###
FormPage = React.createClass

  getInputs: (inputObjects) ->
    inputs = []
    for inputObject in inputObjects
      inputObject.className = "form-input"
      inputObject.hintText = ""
      inputObject.ref = inputObject.id
      inputObject.key = inputObject.id
      if inputObject.type == 'hidden'
        inputs.push React.createElement "input", inputObject
        continue

      inputs.push React.createElement TextField, inputObject
    return inputs

  _onSubmit: (e) ->
    # Get the values for all the fields and then call the parent's onSubmit with them as the parameter
    fields = {}
    for inputObject in @props.inputs
      id = inputObject.id
      obj = @refs[id]

      # If it's a text field grab that, otherwise get it from the props
      if obj.getValue
        fields[id] = obj.getValue()
      else
        fields[id] = obj.props.value
    @props.onSubmit(fields)

    e.preventDefault()

  clearValues: ->
    for inputObject in @props.inputs
      obj = @refs[inputObject.id]

      # Make sure it's not a hidden field, if it is we don't clear it
      if obj.clearValue
        obj.clearValue()

  render: () ->
    <div className="mui-app-content-canvas container">
      <div className="page-header">
        <h1>{@props.pageHeader}</h1>
      </div>
      <Paper className="default-paper form-paper">
        <div className="form-container">
          <form className="form-horizontal" onSubmit={@_onSubmit} method="POST">
            {@getInputs @props.inputs}
            <RaisedButton type="submit" label={@props.submitLabel} primary=true />
          </form>
        </div>
      </Paper>
    </div>

module.exports = FormPage
