module.exports = (sequelize, DataTypes) ->
  MessageData = sequelize.define "MessageData",
    value:
      type: DataTypes.BLOB
      allowNull: false
  , classMethods:
    associate: (models) ->
      MessageData.belongsTo(models.Message)
  , instanceMethods:
    toJSON: ->
      # Convert the byte array to readable text
      return {
        @id
        value: String.fromCharCode.apply(String, @value)
      }
  return MessageData
