module.exports = (sequelize, DataTypes) ->
  Message = sequelize.define "Message",
    hidden:
      type: DataTypes.BOOLEAN
      validate: {notNull: true}
    type:
      type: DataTypes.INTEGER
      validate: {notNull: true}
  , classMethods:
    associate: (models) ->
      Message.belongsTo models.User, {as: 'Author'}
      Message.belongsTo models.Message, {as: 'Parent'}
      Message.hasMany models.Message, {as: 'Children'}
      Message.belongsTo models.Thread
      Message.hasOne models.MessageData

  return Message
