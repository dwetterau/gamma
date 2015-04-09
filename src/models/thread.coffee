module.exports = (sequelize, DataTypes) ->
  Thread = sequelize.define "Thread",
    displayName:
      type: DataTypes.STRING(64)
      allowNull: false
  , classMethods:
    associate: (models) ->
      Thread.hasMany(models.Message)
      Thread.belongsToMany models.User, {as: 'Members', through: 'UserThread'}
  , instanceMethods:

    toJSON: ->
      displayName: @displayName
      id: @id

  return Thread
