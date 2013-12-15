
# Import modules
express    = require 'express'
RedisStore = require('connect-redis') express
modules    = require './src/modules'

# Get modules
auth    = modules.auth
api     = modules.api

# Node configs
Error.stackTraceLimit = 10

# Init app
app = express()

# Express configurations
app.use express.favicon()
app.use express.logger("dev")
app.use express.bodyParser()
app.use express.methodOverride()
app.use express.cookieParser()
app.use express.session {
  secret: 'whatever you think, think the opposite'
  store: new RedisStore {
    host: 'localhost'
    port: 6379
  }
  cookie: {
    maxAge: 3600000
  }
}
app.use express['static']('src/views/login')


# Server variables
app.set 'port', 8005
app.set 'api', api
app.set 'auth', auth
app.set 'test-mode', process.env.NODE_ENV == 'test'

# Setup auth
auth.setup app

# Setup api
api.setup app

# Express configurations (cont)
app.use app.router

# Login handler
app.get '/login', (req, res) ->
  if req.isAuthenticated()
    res.redirect '/'
  else
    res.sendfile __dirname + '/src/views/login/login.html'

# Get session status
app.get '/session', (req, res) ->

  if req.isAuthenticated()
    res.json {
      "authenticated": req.isAuthenticated()
      "current_user" : {
        id         : req.user.id
        name       : req.user.name
        email      : req.user.email
        socialId   : req.user.socialId
        socialType : req.user.socialType
        social     : JSON.parse req.user.social
        createdAt  : req.user.createdAt
        updatedAt  : req.user.updatedAt
      }
    }
  else
    res.send 401

# Logout handler
app.get '/logout', (req, res) ->
  req.logout()
  res.redirect '/'

# Home
app.get '/', auth.middleware(), (req, res) ->
  app.use express.static 'clients/web-app/build/'
  res.sendfile 'clients/web-app/build/index.html'

# For every other route, check with auth
app.use auth.middleware()

# Listen
app.listen app.get('port'), () ->
  console.log 'Server started on port ' + app.get('port')
