# Import modules
BaseModel = require './_base'
moment    = require 'moment'
sqeueu    = require '../services/social-count-write-queue.coffee'
url_util  = require 'url'
clc       = require 'cli-color'
Q         = require 'q'
_         = require 'underscore'

# Facade
class UserBookmark extends BaseModel

  # Define schema for UserBookmark
  setup: (app, sequelize, Sequelize) ->

    @app = app

    # Setup queue
    sqeueu.setup app

    # TODO: add user bookmarked count

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
      opened    : {
        type: Sequelize.BOOLEAN
        defaultValue: false
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
      created_at: {
        type: Sequelize.DATE
      }
      updated_at: {
        type: Sequelize.DATE
      }
    }, {
      # timestamps: false
    }

  expose: () ->

    # GET    /users/:id/bookmarks      - Retrieves all bookmarks of a user
    # GET    /users/:id/bookmarks/:bid - Get a specific bookmark of a user
    # POST   /users/:id/bookmarks      - Creates new bookmark(s) for a user
    # PUT    /users/:id/bookmarks/:bid - Updates a bookmark of a user
    # DELETE /users/:id/bookmarks/:bid - Deletes a bookmark of a user

    # Modules
    scp = @api().services.social_count_poller;

    # Get prefix
    _p = @api().prefix()

    # Open web socket
    @app.get('io').sockets.on 'connection', (socket) =>

      # ----------------------------------------------------------------
      # Gets all bookmarks of a user
      # ----------------------------------------------------------------
      @app.get _p + '/users/:id/bookmarks/', (req, res) =>

        # Grab user
        user = req._user
        delete req._user

        # Get user bookmarks
        user
        .getBookmarks({
          where: {
            'archived': false
            'opened'  : false
          }
          attributes: [
            'Bookmarks.id'
            'Bookmarks.url'
            'Bookmarks.title'
            'Bookmarks.host'
          ]
          joinTableAttributes: [
            'facebook'
            'twitter'
            'linkedin'
            'pinterest'
            'created_at'
          ]
        })
        .success (results) =>
          results = _.map results, (r) =>
            @deserialize _.extend r.values, r.UserBookmark.values
          res.send 200, results

      # ----------------------------------------------------------------
      # Creates bookmark(s) for a user
      # ----------------------------------------------------------------
      @app.post _p + '/users/:uid/bookmarks/', (req, res) =>

        # Grab user
        user = req._user
        delete req._user

        # Grab single bookmark
        bookmark = @serialize req.body
        url      = bookmark.url
        host     = url_util.parse(url).host
        delete bookmark.url

        # Next, create/find the bookmark
        @api()
        .$get('bookmark')
        .findOrCreate({
          'url'  : url
          'host' : host
        }, bookmark)
        .error (errors) =>
          @errors.DB_ERROR(errors, res)
        .success (b) =>

          # Increment bookmark count
          b.increment 'bookmarked_count', {
            by: 1
          }
          b.increment 'active_count', {
            by: 1
          }

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

            # User bookmark already exists
            if userBookmark

              # Re-bookmark
              if userBookmark.values.archived or userBookmark.values.opened

                # Unarchive
                userBookmark
                .updateAttributes({
                  'archived' : false
                  'opened'   : false
                  'created_at': moment(Date.now()).utc().format()
                  'updated_at': moment(Date.now()).utc().format()
                })
                .success (ub) =>

                  # Add to squeue
                  sqeueu.push {
                    user_bookmark : ub
                    bookmark      : b
                  }

                  res.json 201, @deserialize ub.values

                # Start timer to archive it
                _.delay () =>

                  # Archive it
                  if userBookmark
                    userBookmark
                    .updateAttributes({
                      'archived': true
                    })
                    .success () ->
                      # Decrement bookmark active count
                      b.decrement 'active_count', {
                        by: 1
                      }
                      # Increment archived count
                      b.increment 'archived_count', {
                        by: 1
                      }

                , 60 * 1000 * 60 * 24 # 24 hours

              else
                @errors.CUSTOM_MESSAGE('User bookmark already exists.', res);

            else

              # Then create user bookmark
              @api()
              .$get('user-bookmark')
              .create({
                BookmarkId : b.id
                UserId     : user.id
                created_at  : moment(Date.now()).utc().format()
                updated_at  : moment(Date.now()).utc().format()
              })
              .success (user_bookmark_created) =>

                # Respond
                res.json 201, @deserialize b.values

                # Start timer to archive it
                _.delay () =>

                  # Archive it
                  if user_bookmark_created
                    user_bookmark_created
                    .updateAttributes({
                      'archived'  : true
                      'updated_at' : moment(Date.now()).utc().format()
                    })
                    .success () ->
                      # Decrement bookmark active count
                      b.decrement 'active_count', {
                        by: 1
                      }
                      # Increment archived count
                      b.increment 'archived_count', {
                        by: 1
                      }

                , 60 * 1000 * 60 * 24 # 24 hours

                # Add to squeue
                sqeueu.push {
                  user_bookmark : user_bookmark_created
                  bookmark      : b
                }

              .error (e) =>
                @errors.DB_ERROR errors, res

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

        # Get the bookmark requested
        user
        .getBookmarks({
          where: {
            'UserId'  : user.id
            'archived': false
            'opened'  : false
          }
          attributes: [
            'id'
            'url'
            'title'
          ]
          joinTableAttributes: [
            'facebook'
            'twitter'
            'linkedin'
            'pinterest'
          ]
        })
        .success (results) =>

          if results and !!results.length
            results = _.map results, (r) =>
              @deserialize _.extend r.values, r.UserBookmark.values
            res.send results[0]
          else
            @errors.CUSTOM_MESSAGE 'User bookmark does not exists', res

      # ----------------------------------------------------------------
      # Open specific bookmark for a user
      # ----------------------------------------------------------------
      @app.patch _p + '/users/:uid/bookmarks/:bid/', (req, res) =>

        # Grab user
        user = req._user
        delete req._user

        # Grab bookmark
        bookmark = req._bookmark
        delete req._bookmark

        # Update opened count
        bookmark
        .increment 'opened_count', {
          by: 1
        }
        bookmark
        .decrement 'active_count', {
          by: 1
        }

        # Update opened bookmark table
        @api()
        .$get('opened-bookmark')
        .create({
          BookmarkId : bookmark.id
          UserId     : user.id
        })
        .success (ob) ->
          console.log 'Opened bookmark logged successfully'
        .error (e) ->
          throw new Error "Error logging timestamp for opened bookmark: #{ e }"


        # Find user bookmark
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
            userBookmark
            .updateAttributes({
              'opened'     : true
              'updated_at'  : moment(Date.now()).utc().format()
            })

        .error () ->
          throw new Error 'Error updating user bookmark while opening bookmark'


        res.send 200

      # ----------------------------------------------------------------
      # Poll user bookmark social data
      # ----------------------------------------------------------------

      socket.on 'poll:start', (data) =>

        # Grab types
        types = data.types

        # Grab user bookmarks
        user_bookmarks = data.bookmarks

        # Grab urls
        urls = _.map user_bookmarks, (b) ->
          b.url

        # Grab user
        user = data.user

        # Poll
        $fb_poller   = @app.get('api').services.social_count_poller.facebook
        $twtr_poller = @app.get('api').services.social_count_poller.twitter

        $poller = () ->
          arr = []

          # fb
          arr.push $fb_poller(urls)

          # twtr
          _.each urls, (u) ->
            arr.push $twtr_poller(u)

          arr

        promises = $poller(urls)

        Q
        .all(promises)
        .then (social_data) =>

          fb_data   = social_data.shift();
          twtr_data = social_data;

          user_bookmarks = _.map user_bookmarks, (ubb, i) ->
            ubb.facebook = fb_data[i]
            ubb.twitter = twtr_data[i]
            ubb

          user_bookmarks_social_index = _.indexBy user_bookmarks, 'id'

          # Server update
          _.each user_bookmarks, (b) =>

            ubp = Q.defer()
            bp  = Q.defer()

            @api()
            .$get('user-bookmark')
            .find({
              where: {
                BookmarkId : b.id
                UserId     : user.id
              }
            })
            .success (dub) ->
              ubp.resolve(dub);

            @api()
            .$get('bookmark')
            .find(b.id)
            .success (db) ->
              bp.resolve(db)

            Q
            .all([ubp.promise, bp.promise])
            .then (results) ->
              dub = results[0]
              db  = results[1]

              _.each types, (t, i) ->

                fresh_social_data = user_bookmarks_social_index[db.values.id][t]
                if !_.isEqual(JSON.parse(dub.values[t]).current, fresh_social_data)
                  console.log clc.green('Saving updated social data')
                  sqeueu.save dub, db, t, {
                    'current': fresh_social_data
                  }
                else
                  console.log clc.green('Social data same, not updating')

          # Client update
          socket.emit 'poll:finish', {
            data: {
              fb   : fb_data
              twtr : twtr_data
            }
          }

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
          if userBookmark and not userBookmark.values.archived

            userBookmark
            .updateAttributes _.extend bookmarkBody, {
              updated_at  : moment(Date.now()).utc().format()
            }
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
            UserId     : user.id
          }
        })
        .success (userBookmark) =>

          # Archive user bookmark
          if userBookmark
            userBookmark
            .updateAttributes({
              'archived'  : true
              'updated_at' : moment(Date.now()).utc().format()
            })
            .success () ->
              # Decrement bookmark active count
              bookmark.decrement 'active_count', {
                by: 1
              }
              # Increment archived count
              bookmark.increment 'archived_count', {
                by: 1
              }

              # Respond
              res.send 204

            .error (errors) =>
              @errors.DB_ERROR errors, res
          else
            @errors.NOT_FOUND('user bookmark', res)

# Exports
module.exports = new UserBookmark
