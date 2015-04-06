module.exports = (sequelize, DataTypes) ->
  MessageData = sequelize.define "MessageData",
    value: {
      type: DataTypes.BLOB
    }
  , classMethods:
    associate: (models) ->
      MessageData.belongsTo(models.Message)

  return MessageData
