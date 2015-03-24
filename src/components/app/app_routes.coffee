React = require 'react'
Router = require 'react-router'
Route = Router.Route
Redirect = Router.Redirect
DefaultRoute = Router.DefaultRoute

Master = require '../pages/master'

Home = require '../pages/home'
UserLogin = require '../pages/user/login'

AppRoutes = (
  <Route name="root" path="/" handler={Master}>
    <Route name="home" handler={Home} />
    <Route name="user/login" handler={UserLogin} />
    <DefaultRoute handler={Home} />
  </Route>
)

module.exports = AppRoutes