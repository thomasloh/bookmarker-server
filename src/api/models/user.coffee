# Import modules

# Internals
model = null
$app   = null

# Facade
user = {

  # Define schema for User
  setup: (app, sequelize, Sequelize) ->

    $app = app

    model = sequelize.define 'User', {
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


  $: () ->
    return model if model

  api: () ->
    $app.get 'api'

  pipe: (req, res, callback) ->
    return (results) ->
      res.json results

  expose: () ->
    # GET    /users     - Retrieves all users
    # GET    /users/:id - Retrieves a specific user
    # POST   /users     - Creates a new user
    # PUT    /users/:id - Updates an existing user
    # DELETE /users/:id - Deletes an existing user

    # GET    /users/:id/bookmarks      - Retrieves all bookmarks of a user
    # GET    /users/:id/bookmarks/:bid - Get a specific bookmark of a user
    # POST   /users/:id/bookmarks      - Creates a new bookmark for a user
    # PUT    /users/:id/bookmarks/:bid - Updates a bookmark of a user
    # DELETE /users/:id/bookmarks/:bid - Deletes a bookmark of a user

    # Get prefix
    _p = @api().prefix()

    # Get all users
    $app.get _p + '/users', (req, res) =>
      @all().then @pipe req, res

    # Get specific user by id
    $app.get _p + '/users/:id', (req, res) =>
      @get(req.params.id).then @pipe req, res

    # Creates a new user
    $app.post _p + '/users', (req, res) =>
      @create req.body, res

    # Updates an existing user
    $app.put _p + '/users/:id', (req, res) =>
      @update req.params.id, req.body, res

    # Deletes an existing user
    $app.delete _p + '/users/:id', (req, res) =>
      @destroy req.params.id, res

  all: () ->
    @api().get('user').all()

  get: (id) ->
    @api().get('user').find(id)

  create: (attrs, res) ->
    # Build new instance
    user = @api().get('user').build attrs

    # Validate
    user
    .validate()
    .success (errors) ->
      # Send validation errors, if any
      if errors
        res.json {
          errors: errors
        }
      else
      # Proceed to create user
        user
        .save()
        .success (u) ->
          # 201 - User created
          res.send 201, u.values
        .error (errors) ->
          # 400 - Error creating user
          res.send 400, {
            errors: errors
          }

  update: (id, attrs, res) ->

    # Get existing user
    @get(id)
    .success (user) ->
      if user
        # Proceed to update user
        user
        .updateAttributes(attrs)
        .success (u) ->
          # 200 - User updated
          res.send 200, u.values
        .error (errors) ->
          # 400 - Send validation errors, if any
          res.send 400, {
            errors: errors
          }
      else
        # 400 - User not found
        res.send 400, {
          errors: {
            message: "User not found"
          }
        }

  destroy: (id, res) ->

    # Get existing user
    @get(id)
    .success (user) ->
      if user
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
      else
        # 400 - User not found
        res.send 400, {
          errors: {
            message: "User not found"
          }
        }

}





# Exports
module.exports = user
