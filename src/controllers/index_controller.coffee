exports.get_index = (req, res) ->
  title = 'Home'
  render_dict = {
    navigation: JSON.stringify
      tab: title,
      user: if req.user then req.user.to_json() else undefined
    user: req.user
    title
  }
  res.render 'index', render_dict
