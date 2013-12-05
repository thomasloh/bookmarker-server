# Import modules
Sequelize    = require 'sequelize'
User         = require './models/user'
Bookmark     = require './models/bookmark'
UserBookmark = require './models/user-bookmark'

# Constants
_d      = require './configuration/db'
VERSION = 'v1'
PREFIX  = 'api'

# Reusables
sequelize = null
$app       = null

# Internals
models = {
  'user'          : User
  'bookmark'      : Bookmark
  'user-bookmark' : UserBookmark
}

# Facade
api = {

  prefix: () ->
    return '/' + PREFIX + '/' + VERSION

  # API setup phase
  setup: (app) ->

    # Store app
    $app = app

    # Connect to database
    sequelize = new Sequelize _d.DB_NAME, _d.DB_USER, _d.DB_PASS, {

      host: _d.DB_URL

      port: _d.DB_PORT

      dialect: 'postgres'
    }

    @initTables()


  initTables: () ->

    # Setup schemas
    User.setup $app, sequelize, Sequelize
    Bookmark.setup $app, sequelize, Sequelize
    UserBookmark.setup $app, sequelize, Sequelize

    # Setup joins
    @$get('user').hasMany @$get('bookmark'), {
      joinTableModel: UserBookmark.$()
      onDelete      : 'restrict'
    }
    @$get('bookmark').hasMany @$get('user'), {
      joinTableModel: UserBookmark.$()
      onDelete      : 'restrict'
    }

    sequelize.sync force: $app.get 'test-mode'

    # Expose endpoints
    @expose()

  # Get model
  $get: (type) ->
    return models[type].$() if models[type]

  # Get Sequelize class
  get: (type) ->
    return models[type] if models[type]

  # Expose endpoints
  expose: () ->

    # TODO: CORS

    # Secure REST API
    $app.all @prefix() + '*', (req, res, next) ->

      if $app.get('auth').isLoggedIn(req) || $app.get 'test-mode'
        next()
      else
        res.send 401

    # Entity preprocessors
    User.preprocess()
    Bookmark.preprocess()

    # Entity endpoints
    User.expose()
    Bookmark.expose()
    UserBookmark.expose()

    # ----------------------------------------------------------------
    # Test env only
    # ----------------------------------------------------------------

    if !$app.get 'test-mode'
      return

    # Delete all users
    $app.delete @prefix() + '/all/', (req, res) =>

      sequelize
      .sync(force: true)
      .success () ->
        res.send 204

}





# Exports
module.exports = api
