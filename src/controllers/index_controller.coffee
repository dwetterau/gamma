exports.get_index = (req, res) ->
  res.render 'index', {
    props: JSON.stringify
      user: if req.user then req.user.to_json() else undefined
  }
