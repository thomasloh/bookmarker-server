# Import modules
BaseModel = require './_base'
_v        = require '../utils/validator'

# Facade
class Bookmark extends BaseModel

  # Define schema for Bookmark
  setup: (app, sequelize, Sequelize) ->

    @app = app

    @model = sequelize.define 'Bookmark', {
      url      : {
        type: Sequelize.TEXT
        validate: {
          isUrl    : true
          notEmpty : true
        }
      }
      title    : {
        type: Sequelize.TEXT
        validate: {
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

  preprocess: () ->

    # ----------------------------------------------------------------
    # Validations
    # ----------------------------------------------------------------
    @app.all '*/bookmarks/:id/*', (req, res, next) =>

      # Grab bookmark id
      boomarkId = req.params[0]

      # Check for bookmark existence
      @api()
      .$get('bookmark')
      .find(boomarkId)
      .success (bookmark) =>
        if bookmark
          # Tack bookmark found to next middleware
          req._bookmark = bookmark
          next()
        else
          @errors.NOT_FOUND 'bookmark', res
      .error () =>
        @errors.NOT_FOUND 'bookmark', res

  expose: () ->
    # GET    /bookmarks     - Retrieves all bookmarks
    # GET    /bookmarks/:id - Retrieves a specific bookmark
    # POST   /bookmarks     - Creates a new bookmark
    # PUT    /bookmarks/:id - Updates an existing bookmark
    # DELETE /bookmarks/:id - Deletes an existing bookmark

    # Get prefix
    _p = @api().prefix()

    # ----------------------------------------------------------------
    # Creates a new bookmark
    # ----------------------------------------------------------------
    @app.post _p + '/bookmarks/', (req, res) =>

      return @errors.CUSTOM_MESSAGE('Not allowed', res)

    # ----------------------------------------------------------------
    # Get all bookmarks
    # ----------------------------------------------------------------
    @app.get _p + '/bookmarks/', (req, res) =>
      @api()
      .$get('bookmark')
      .all()
      .then @pipe req, res

    # ----------------------------------------------------------------
    # Get specific bookmark by id
    # ----------------------------------------------------------------
    @app.get _p + '/bookmarks/:id/', (req, res) =>

      # Grab bookmark
      bookmark = req._bookmark
      delete req._bookmark

      # Respond
      res.json bookmark

    # ----------------------------------------------------------------
    # Updates an existing bookmark
    # ----------------------------------------------------------------
    @app.put _p + '/bookmarks/:id/', (req, res) =>

      return @error.CUSTOM_MESSAGE('Not allowed', res)

      # Grab bookmark
      bookmark = req._bookmark
      delete req._bookmark

      # Proceed to update bookmark
      bookmark
      .updateAttributes(req.body)
      .success (u) ->
        # 200 - bookmark updated
        res.send 200, @deserialize(u.values)
      .error (errors) ->
        # 400 - Send validation errors, if any
        res.send 400, {
          errors: errors
        }

    # ----------------------------------------------------------------
    # Deletes an existing bookmark
    # ----------------------------------------------------------------
    @app.delete _p + '/bookmarks/:id/', (req, res) =>

      return @error.CUSTOM_MESSAGE('Not allowed', res)

      # Grab bookmark
      bookmark = req._bookmark
      delete req._bookmark

      # Proceed to delete bookmark
      bookmark
      .destroy()
      .success () ->
        # 204- bookmark deleted
        res.send 204
      .error () ->
        # 400 - Error deleting bookmark
        res.send 400, {
          errors: errors
        }

    # ----------------------------------------------------------------
    # TODO: Get users of a bookmark
    # ----------------------------------------------------------------
    @app.get _p + '/bookmarks/:id/users/', (req, res) =>



# Exports
module.exports = new Bookmark
