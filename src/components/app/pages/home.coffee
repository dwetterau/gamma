React = require 'react'

Home = React.createClass
  contextTypes: {
    router: React.PropTypes.func
  }

  render: ->
    return (
      <div className="mui-app-content-canvas">
        Hello World!
      </div>
    )

module.exports = Home
