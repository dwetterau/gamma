exports.get_index = (req, res) ->
  res.render 'layout', {
    props: JSON.stringify
      user: if req.user then req.user.toJSON() else undefined
  }
