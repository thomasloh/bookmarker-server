
# Import modules
express = require 'express'
modules = require('./src/modules')

# Get modules
auth    = modules.auth
api     = modules.api

# Init app
app = express()

# Express configurations
app.use express.favicon()
app.use express.logger("dev")
app.use express.bodyParser()
app.use express.methodOverride()
app.use express.cookieParser()
app.use express.session { secret: 'whatever you think, think the opposite' }

# Server variables
app.set 'port', 8005
app.set 'api', api
app.set 'auth', auth

# Setup auth
auth.setup app

# Setup api
api.setup app

# Express configurations (cont)
app.use app.router

# Home
app.get '/', auth.middleware(), (req, res) ->
  res.end 'Hello World!'

app.get '/login', (req, res) ->
  app.use express['static']('src/views/login')
  res.sendfile __dirname + '/src/views/login/login.html'

# Listen
app.listen app.get('port'), () ->
  console.log 'Server started on port ' + app.get('port')
