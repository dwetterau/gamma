module.exports = (sequelize, DataTypes) ->
  Thread = sequelize.define "Thread",
    displayName:
      type: DataTypes.STRING(64)
      validate: {notNull: true}
  , classMethods:
    associate: (models) ->
      Thread.hasMany(models.Message)
      Thread.belongsToMany models.User, {as: 'Members', through: 'UserThread'}

  return Thread
