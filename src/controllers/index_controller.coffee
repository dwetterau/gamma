exports.get_index = (req, res) ->
  render_dict = {
    navigation: JSON.stringify
      tab: @title,
      user: if req.user then req.user.to_json() else undefined
    user: req.user
    title: 'Home'
  }
  res.render 'index', render_dict
