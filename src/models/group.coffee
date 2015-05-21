module.exports = (sequelize, DataTypes) ->
  Group = sequelize.define "Group",
    displayName:
      type: DataTypes.STRING(64)
      allowNull: false
  , classMethods:
    associate: (models) ->
      Group.belongsToMany models.Contact, {as: 'Contacts', through: 'GroupContact'}
  , instanceMethods:

    toJSON: ->
      displayName: @displayName
      id: @id

  return Group
