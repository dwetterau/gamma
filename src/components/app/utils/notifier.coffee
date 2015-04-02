Notifier =
  info: (message) ->
    $.snackbar {
      content: message
      timeout: 3000
    }

  error: (message, exception) ->
    $.snackbar {
      content: message
      timeout: 3000
    }
    if exception?
      console.error exception

module.exports = Notifier