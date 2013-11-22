# Import modules

# Internals
model = null
$app = null

# Facade
userbookmark = {

  # Define schema for UserBookmark
  setup: (app, sequelize, Sequelize) ->

    $app = app

    model = sequelize.define 'UserBookmark', {
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
    }

  $: () ->
    return model if model

}

# Exports
module.exports = userbookmark
