# Import modules
BaseModel = require './_base'
_         = require 'underscore'

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

  expose: () ->

    # GET    /users/:id/bookmarks      - Retrieves all bookmarks of a user
    # GET    /users/:id/bookmarks/:bid - Get a specific bookmark of a user
    # POST   /users/:id/bookmarks      - Creates new bookmark(s) for a user
    # PUT    /users/:id/bookmarks/:bid - Updates a bookmark of a user
    # DELETE /users/:id/bookmarks/:bid - Deletes a bookmark of a user

    # Get prefix
    _p = @api().prefix()

    # ----------------------------------------------------------------
    # Gets all bookmarks of a user
    # ----------------------------------------------------------------
    @app.get _p + '/users/:id/bookmarks/', (req, res) =>

      # Grab user
      user = req._user
      delete req._user

      # Get user bookmarks
      @api()
      .$get('user-bookmark')
      .findAll({
        where: {
          UserId: user.id
        }
      })
      .success (results) =>
        results = _.map results, (r) =>
          @deserialize r.values
        res.send 200, results

    # ----------------------------------------------------------------
    # Creates bookmark(s) for a user
    # ----------------------------------------------------------------
    @app.post _p + '/users/:id/bookmarks/', (req, res) =>

      # Grab user
      user = req._user
      delete req._user

      # Grab single bookmark
      bookmark = req.body

      # Next, create/find the bookmark
      @api()
      .$get('bookmark')
      .findOrCreate(@serialize(bookmark))
      .error (errors) =>
        @errors.DB_ERROR(errors, res)
      .success (b) =>

        # Check for existence first
        @api()
        .$get('user-bookmark')
        .find({
          where: {
            BookmarkId : b.id
            UserId     : user.id
          }
        })
        .success (userBookmark) =>

          if userBookmark
            @errors.CUSTOM_MESSAGE('User bookmark already exists.', res);
          else
            # Then create user bookmark
            user
            .addBookmark(b)
            .success (ub) =>
              res.json 201, @deserialize(ub.values)
            .error (e) =>
              @errors.DB_ERROR(errors, res)

            # Increment bookmark count
            b.increment 'count', 1

    # ----------------------------------------------------------------
    # Get specific bookmark for a user
    # ----------------------------------------------------------------
    @app.get _p + '/users/:uid/bookmarks/:bid/', (req, res) =>

      # Grab user
      user = req._user
      delete req._user

      # Grab bookmark
      bookmark = req._bookmark
      delete req._bookmark

      # Check for user bookmark existence first
      @api()
      .$get('user-bookmark')
      .find({
        where: {
          BookmarkId : bookmark.id
          UserId     : user.id
        }
      })
      .success (userBookmark) =>
        if userBookmark
          res.json 200, @deserialize(userBookmark.values)
        else
          @errors.CUSTOM_MESSAGE 'User bookmark does not exists', res

    # ----------------------------------------------------------------
    # Update bookmark for a user
    # ----------------------------------------------------------------
    @app.put _p + '/users/:uid/bookmarks/:bid/', (req, res) =>

      # Grab user
      user = req._user
      delete req._user

      # Grab bookmark
      bookmark = req._bookmark
      delete req._bookmark

      # Grab bookmark body
      validJSON = true
      try
        JSON.stringify req.body
      catch e
        validJSON = false

      if !validJSON
        return @errors.CUSTOM_MESSAGE 'Must provide valid JSON', res

      bookmarkBody = @serialize(req.body)

      # Check for user bookmark existence first
      @api()
      .$get('user-bookmark')
      .find({
        where: {
          BookmarkId : bookmark.id
          UserId     : user.id
        }
      })
      .success (userBookmark) =>

        # Updates user bookmark
        if userBookmark

          userBookmark
          .updateAttributes(bookmarkBody)
          .success (ub) =>
            # Respond
            res.json 200, @deserialize(ub.values)
          .error (errors) ->
            res.send 400, {
              errors: errors
            }
        else
          @errors.NOT_FOUND('user bookmark', res)

    # ----------------------------------------------------------------
    # Delete bookmark øf a user
    # ----------------------------------------------------------------
    @app.delete _p + '/users/:uid/bookmarks/:bid/', (req, res) =>

      # Grab user
      user = req._user
      delete req._user

      # Grab bookmark
      bookmark = req._bookmark
      delete req._bookmark

      # Check for existence first
      @api()
      .$get('user-bookmark')
      .find({
        where: {
          BookmarkId : bookmark.id
          UserId     : userId
        }
      })
      .success (userBookmark) =>

        # Delete user bookmark
        if userBookmark
          userBookmark
          .destroy()
          .success () ->
            # Decrement bookmark count
            b.decrement 'count', 1

            # Respond
            res.send 204

          .error (errors) =>
            @errors.DB_ERROR errors, res
        else
          @errors.NOT_FOUND('user bookmark', res)


# Exports
module.exports = new UserBookmark
