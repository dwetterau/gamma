React = require 'react'

# Client-side stuff here

# Render user forms
if $('#create_account').length
  {CreateUser} = require '../../components/user/create_user'
  React.render React.createElement(CreateUser, null), $('#create_account').get(0)

if $('#change_password').length
  {ChangePassword} = require '../../components/user/change_password'
  React.render React.createElement(ChangePassword, null), $('#change_password').get(0)

if $('#login').length
  {Login} = require '../../components/user/login'
  props = JSON.parse($('#props').html())
  React.render React.createElement(Login, props), $('#login').get(0)
