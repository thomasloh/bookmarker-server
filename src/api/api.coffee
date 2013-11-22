# Import modules
Sequelize    = require 'sequelize'
User         = require './models/user'
Bookmark     = require './models/bookmark'
UserBookmark = require './models/user-bookmark'

# Constants
DB_NAME     = 'leafydb'
DB_USER     = 'thomasloh'
DB_PASS     = 'bookmarkmuch'
DB_URL      = 'leafydb.cw8d91rc6nbp.us-west-2.rds.amazonaws.com'
DB_PORT     = 5432

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
    sequelize = new Sequelize DB_NAME, DB_USER, DB_PASS, {

      host: DB_URL

      port: DB_PORT

      dialect: 'postgres'
    }

    # Setup schemas
    User.setup app, sequelize, Sequelize
    Bookmark.setup app, sequelize, Sequelize
    UserBookmark.setup app, sequelize, Sequelize

    # @drop()

    # Recreates table
    @get('user').sync()
    @get('bookmark').sync()

    # Setup joins
    @get('user').hasMany @get('bookmark'), {
      joinTableModel: UserBookmark.$()
    }
    @get('bookmark').hasMany @get('user'), {
      joinTableModel: UserBookmark.$()
    }

    sequelize.sync()

    # Expose endpoints
    @expose()

  # Get model
  get: (type) ->
    return models[type].$() if models[type]

  # Expose endpoints
  expose: () ->

    # TODO: CORS

    # Secure REST API
    $app.all @prefix() + '*', (req, res, next) ->

      if $app.get('auth').isLoggedIn(req)
        next()
      else
        res.send 401

    # Users
    User.expose()

  # Drop all tables
  drop: () ->
    @get('user').drop()
    @get('bookmark').drop()
    UserBookmark.$().drop()


}





# Exports
module.exports = api
