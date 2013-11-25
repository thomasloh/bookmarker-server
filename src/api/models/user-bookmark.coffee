# Import modules
BaseModel = require './_base'
Q         = require 'q'

# Facade
class UserBookmark extends BaseModel

  # Define schema for UserBookmark
  setup: (app, sequelize, Sequelize) ->

    @app = app

    @model = sequelize.define 'UserBookmark', {
      facebook  : {
        type      : Sequelize.TEXT
        allowNull : true
      }
      twitter   : {
        type      : Sequelize.TEXT
        allowNull : true
      }
      linkedin  : {
        type      : Sequelize.TEXT
        allowNull : true
      }
      pinterest : {
        type      : Sequelize.TEXT
        allowNull : true
      }
      archived  : {
        type: Sequelize.BOOLEAN
        defaultValue: false
      }
      BookmarkId: {
        type: Sequelize.INTEGER
        references: "Bookmarks"
        referencesKey: "id"
      }
      UserId: {
        type: Sequelize.INTEGER
        references: "Users"
        referencesKey: "id"
      }

    }

  # Retrieves user bookmarks
  getByUser: (uid) ->
    @api()
    .$get('user-bookmark')
    .find {
      where: {
        UserId: uid
      }
    }

  # TODO: Bulk creates user bookmarks
  bulkCreate: (bookmarks) ->

  # Creates user bookmark
  create: (userBookmark) ->
    console.log(userBookmark)
    @api()
    .$get('user-bookmark')
    .create userBookmark

# Exports
module.exports = new UserBookmark
