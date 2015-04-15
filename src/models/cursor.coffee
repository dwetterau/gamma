module.exports = (sequelize, DataTypes) ->
  Cursor = sequelize.define "Cursor",
    viewTime:
      type: DataTypes.DATE
      allowNull: false
  , classMethods:
    associate: (models) ->
      Cursor.belongsTo(models.Thread)
      Cursor.belongsTo(models.User)
  , instanceMethods:

    toJSON: ->
      viewTime: @viewTime
      id: @id

  return Cursor
