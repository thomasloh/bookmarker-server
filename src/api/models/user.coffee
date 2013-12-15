# Import modules
BaseModel = require './_base'
_         = require 'underscore'

# Facade
class User extends BaseModel

  # Define schema for User
  setup: (app, sequelize, Sequelize) ->

    @app = app

    @sequelize = sequelize

    @model = sequelize.define 'User', {
      name      : {
        type: Sequelize.STRING
        validate: {
          is       : ['[a-zA-Z\s]+', 'i']
          notEmpty : true
          notNull  : true
        }
      }
      email     : {
        type: Sequelize.STRING
        allowNull: true
        validate: {
          isEmail: true
        }
      }
      socialId  : {
        type: Sequelize.TEXT
        allowNull: true
      }
      socialType: {
        type: Sequelize.STRING
        allowNull: true
        validate: {
          isIn: [['twitter', 'facebook']]
        }
      }
      social    : {
        type     : Sequelize.TEXT
        allowNull: true
      }
    }


  preprocess: () ->

    # ----------------------------------------------------------------
    # Validations
    # ----------------------------------------------------------------
    @app.all '*/users/:id/*', (req, res, next) =>

      # Grab user id
      userId = req.params[0]

      # Check for user existence
      @api()
      .$get('user')
      .find(userId)
      .success (user) =>
        if user
          # Tack user found to next middleware
          req._user = user
          next()
        else
          @errors.NOT_FOUND 'user', res
      .error () =>
        @errors.NOT_FOUND 'user', res

  expose: () ->
    # GET    /users     - Retrieves all users
    # GET    /users/:id - Retrieves a specific user
    # POST   /users     - Creates a new user
    # PUT    /users/:id - Updates an existing user
    # DELETE /users/:id - Deletes an existing user

    # Get prefix
    _p = @api().prefix()

    # ----------------------------------------------------------------
    # Get all users
    # ----------------------------------------------------------------

    @app.get _p + '/users/', (req, res) =>
      @api()
      .$get('user')
      .all()
      .then @pipe req, res

    # ----------------------------------------------------------------
    # Get specific user by id
    # ----------------------------------------------------------------

    @app.get _p + '/users/:id/', (req, res) =>

      # Grab user
      user = req._user
      delete req._user

      # Respond
      res.json @deserialize user.values

    # ----------------------------------------------------------------
    # Creates a new user
    # ----------------------------------------------------------------
    @app.post _p + '/users/', (req, res) =>

      # Build new instance
      user = @api().$get('user').build req.body

      # Validate
      user
      .validate()
      .success (errors) =>
        # Send validation errors, if any
        if errors
          res.json {
            errors: errors
          }
        else
        # Proceed to create user
          user
          .save()
          .success (u) =>
            # 201 - User created
            res.send 201, @deserialize u.values
          .error (errors) ->
            # 400 - Error creating user
            res.send 400, {
              errors: errors
            }

    # ----------------------------------------------------------------
    # Updates an existing user
    # ----------------------------------------------------------------
    @app.put _p + '/users/:id/', (req, res) =>

      # Grab user
      user = req._user
      delete req._user

      # Proceed to update user
      user
      .updateAttributes(req.body)
      .success (u) ->
        # 200 - User updated
        res.send 200, @deserialize u.values
      .error (errors) ->
        # 400 - Send validation errors, if any
        res.send 400, {
          errors: errors
        }

    # ----------------------------------------------------------------
    # Deletes an existing user
    # ----------------------------------------------------------------
    @app.delete _p + '/users/:id/', (req, res) =>

      return @errors.CUSTOM_MESSAGE('Not allowed', res)

      # Grab user
      user = req._user
      delete req._user

      # Proceed to delete user
      user
      .destroy()
      .success () ->
        # 204- User deleted
        res.send 204
      .error () ->
        # 400 - Error deleting user
        res.send 400, {
          errors: errors
        }

# Exports
module.exports = new User
