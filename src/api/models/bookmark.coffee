# Import modules
_v = require '../utils/validator'

# Internals
model = null
$app = null

# Facade
bookmark = {

  # Define schema for Bookmark
  setup: (app, sequelize, Sequelize) ->

    $app = app

    model = sequelize.define 'Bookmark', {
      url      : {
        type: Sequelize.TEXT
        validate: {
          isUrl  : true
          notEmpty : true
        }
      }
      count     : {
        type: Sequelize.INTEGER
        defaultValue: 0
        validate: {
          isNumeric: true
        }
      }
      facebook  : {
        type      : Sequelize.TEXT
        allowNull : true
        validate: {
          isValidFacebookData: _v.isValidFacebookData
        }
      }
      twitter   : {
        type      : Sequelize.TEXT
        allowNull : true
        validate: {
          isValidTwitterData: _v.isValidTwitterData
        }
      }
      linkedin  : {
        type      : Sequelize.TEXT
        allowNull : true
        validate: {
          isValidLinkedInData: _v.isValidLinkedInData
        }
      }
      pinterest : {
        type      : Sequelize.TEXT
        allowNull : true
        validate: {
          isValidPinterestData: _v.isValidPinterestData
        }
      }
    }

  $: () ->
    return model if model

}





# Exports
module.exports = bookmark
