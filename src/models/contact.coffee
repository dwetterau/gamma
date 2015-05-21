module.exports = (sequelize, DataTypes) ->
  Contact = sequelize.define "Contact", {}
  , classMethods:
    associate: (models) ->
      Contact.belongsTo(models.User)
      Contact.belongsToMany models.Group, {through: 'GroupContacts'}
  , instanceMethods:

    toJSON: () ->
      return {
        id: @id
      }

  return Contact
