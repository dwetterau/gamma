express = require 'express'
router = express.Router()
passport_config  = require('../lib/auth')

cursor_controller = require '../controllers/cursor_controller'
index_controller = require '../controllers/index_controller'
message_controller = require '../controllers/message_controller'
notification_controller = require '../controllers/notification_controller'
thread_controller = require '../controllers/thread_controller'
user_controller = require '../controllers/user_controller'

auth = passport_config.isAuthenticated

# GET home page
router.get '/', index_controller.get_index

# User routes
router.post '/api/user/create', user_controller.post_user_create
router.post '/api/user/login', user_controller.post_user_login
router.get '/api/user/logout', user_controller.get_user_logout
router.post '/api/user/password', auth, user_controller.post_change_password

# Thread api routes
# TODO: api route separation and versioning
router.post '/api/thread/create', auth, thread_controller.post_create_thread
router.get '/api/thread/:threadId/messages', auth, thread_controller.get_messages_for_thread
router.get '/api/user/threads', auth, thread_controller.get_threads_for_user

# Message api routes
router.post '/api/message/create', auth, message_controller.post_create_message
router.delete '/api/message/:messageId/delete', auth, message_controller.delete_message

# Cursor api routes
router.get '/api/thread/:threadId/cursor', auth, cursor_controller.get_or_create_cursor
router.post '/api/cursor/:cursorId/update', auth, cursor_controller.post_update_cursor

# Notification api routes
router.get '/api/notifications', auth, notification_controller.get_listen_notifications

# User api routes
router.get '/api/users', auth, user_controller.get_users

# Start the notification server
notification_controller.startNotificationServer()

module.exports = router
