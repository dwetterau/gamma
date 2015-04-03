Notifier =
  info: (message) ->
    $.snackbar {
      content: message
      timeout: 3000
    }

  error: (message, exception) ->
    display = (message) ->
      $.snackbar {
        content: message
        timeout: 3000
      }

    if typeof message == 'object'
      for error in message
        if error.msg?
          display error.msg
        else if error.message?
          display error.message
        else
          display error
    else
      display message

    if exception?
      console.error exception

module.exports = Notifier