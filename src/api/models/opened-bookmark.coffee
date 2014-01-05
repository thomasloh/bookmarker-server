# Import modules
BaseModel = require './_base'
_         = require 'underscore'

# Facade
class OpenedBookmark extends BaseModel

  # Define schema for OpenedBookmark
  setup: (app, sequelize, Sequelize) ->

    @app = app

    # TODO: add user bookmarked count

    @model = sequelize.define 'OpenedBookmark', {
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

  expose: () ->

    # Get prefix
    _p = @api().prefix()


# Exports
module.exports = new OpenedBookmark
