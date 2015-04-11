express = require 'express'
router = express.Router()
passport_config  = require('../lib/auth')

index_controller = require '../controllers/index_controller'
message_controller = require '../controllers/message_controller'
thread_controller = require '../controllers/thread_controller'
user_controller = require '../controllers/user_controller'

auth = passport_config.isAuthenticated

# GET home page
router.get '/', index_controller.get_index

# User routes
router.post '/user/create', user_controller.post_user_create
router.post '/user/login', user_controller.post_user_login
router.get '/user/logout', user_controller.get_user_logout
router.post '/user/password', auth, user_controller.post_change_password

# Thread api routes
router.post '/thread/create', auth, thread_controller.post_create_thread
router.get '/thread/:threadId/messages', auth, thread_controller.get_messages_for_thread

# Message api routes
router.post '/message/create', auth, message_controller.post_create_message

router.REGISTERED_ROUTES = {
  '/user/create', '/user/login', '/user/password'
}

module.exports = router
