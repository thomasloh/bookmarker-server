# Import modules
passport    = require 'passport'
twitterAuth = require './twitter'


# Reusables
$app = null

# Facade
auth = {

  # Passport initialisation setup
  setup: (app) ->

    # Store app
    $app = app

    # Passport session setup
    passport.serializeUser (user, done) ->
      done null, user
    passport.deserializeUser (obj, done) ->
      done null, obj

    # Use passport session
    app.use passport.initialize()
    app.use passport.session()

    # Setup strategies
    twitterAuth.setup passport, app

  middleware: () ->
    (req, res, next) =>
      if @isLoggedIn(req)
        next()
      else
        res.redirect '/login'

  isLoggedIn: (req) ->
    return req.isAuthenticated()

}





# Exports
module.exports = auth
