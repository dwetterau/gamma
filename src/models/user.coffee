bcrypt = require 'bcrypt'

module.exports = (sequelize, DataTypes) ->
  User = sequelize.define "User",
    username:
      type: DataTypes.STRING
      unique: true
      allowNull: false
    password:
      type: DataTypes.STRING
      allowNull: false
  , classMethods:
    associate: (models) ->
      User.hasMany(models.Message)
      User.belongsToMany models.Thread, {through: 'UserThread'}
  , instanceMethods:

    hash_and_set_password: (unhashed_password, next) ->
      bcrypt.genSalt 5, (err, salt) =>
        if err?
          return next(err)
        bcrypt.hash unhashed_password, salt, (err, hash) =>
          if err?
            return next(err)
          @.setDataValue("password", hash)
          next()

    compare_password: (candidatePassword, next) ->
      bcrypt.compare candidatePassword, this.password, (err, is_match) ->
        if err?
          return next(err)
        next(null, is_match)

    toJSON: () ->
      return {
        @username
        @id
      }

  return User
