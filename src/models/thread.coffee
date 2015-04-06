module.exports = (sequelize, DataTypes) ->
  Thread = sequelize.define "Thread",
    displayName:  DataTypes.STRING(64)
  , classMethods:
    associate: (models) ->
      Thread.hasMany(models.Message)
      Thread.belongsToMany models.User, {as: 'Members', through: 'UserThread'}

  return Thread
