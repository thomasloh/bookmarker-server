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

  expose: () ->
    # GET    /bookmarks     - Retrieves all bookmarks
    # GET    /bookmarks/:id - Retrieves a specific bookmark
    # POST   /bookmarks     - Creates a new bookmark
    # PUT    /bookmarks/:id - Updates an existing bookmark
    # DELETE /bookmarks/:id - Deletes an existing bookmark

    # Get prefix
    _p = @api().prefix()

    # Get all bookmarks
    @app.get _p + '/bookmarks', (req, res) =>
      @all().then @pipe req, res

    # Get specific bookmark by id
    @app.get _p + '/bookmarks/:id', (req, res) =>
      @get(req.params.id).then @pipe req, res

    # Creates a new bookmark
    # @app.post _p + '/bookmarks', (req, res) =>
    #   @create req.body, res

    # Updates an existing bookmark
    @app.put _p + '/bookmarks/:id', (req, res) =>
      @update req.params.id, req.body, res

    # Deletes an existing bookmark
    @app.delete _p + '/bookmarks/:id', (req, res) =>
      @destroy req.params.id, res

    @app.get _p + '/bookmarks/:id/users', (req, res) =>
      @api().get('bookmark')


  all: () ->
    @api().$get('bookmark').all()

  get: (id) ->
    @api().$get('bookmark').find(id)

  findOrCreate: (bookmark, callback) ->
    @api()
    .$get('bookmark')
    .findOrCreate(bookmark)
    .success (b) ->
      callback null, b
    .error (errors) ->
      callback errors

  create: (attrs, callback) ->
    # Build new instance
    bookmark = @api().$get('bookmark').build attrs

    # Validate
    bookmark
    .validate()
    .success (errors) ->
      # Send validation errors, if any
      if errors
        callback errors
      else
      # Proceed to create bookmark
        bookmark
        .save()
        .success (u) ->
          callback null, u
        .error (errors) ->
          callback errors

  # TODO: Bulk creates bookmarks
  bulkCreate: (bookmarks) ->

  update: (id, attrs, res) ->

    # Get existing bookmark
    @get(id)
    .success (bookmark) ->
      if bookmark
        # Proceed to update bookmark
        bookmark
        .updateAttributes(attrs)
        .success (u) ->
          # 200 - bookmark updated
          res.send 200, u.values
        .error (errors) ->
          # 400 - Send validation errors, if any
          res.send 400, {
            errors: errors
          }
      else
        # 400 - bookmark not found
        res.send 400, {
          errors: {
            message: "Bookmark not found"
          }
        }

  destroy: (id, res) ->

    # Get existing bookmark
    @get(id)
    .success (bookmark) ->
      if bookmark
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
      else
        # 400 - bookmark not found
        res.send 400, {
          errors: {
            message: "Bookmark not found"
          }
        }



# Exports
module.exports = new Bookmark
