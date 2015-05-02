React = require 'react'
Router = require 'react-router'
Route = Router.Route
Redirect = Router.Redirect
DefaultRoute = Router.DefaultRoute

Layout = require './layout'

Home = require './pages/home'
Thread = require './pages/thread'
UserLogin = require './pages/user/login'
UserChangePassword = require './pages/user/change_password'
UserCreate = require './pages/user/create_user'

AppRoutes = (
  <Route name="root" path="/" handler={Layout}>
    <Route name="/" handler={Home}/>
    <Route name="threads" handler={Home}>
      <Route name="/thread/:threadId" handler={Thread}/>
    </Route>
    <Route name="user/login" handler={UserLogin}/>
    <Route name="user/password" handler={UserChangePassword}/>
    <Route name="user/create" handler={UserCreate}/>
    <DefaultRoute handler={Home} />
  </Route>
)

module.exports = AppRoutes