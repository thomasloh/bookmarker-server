# Import passport-twitter
FacebookStrategy = require('passport-facebook').Strategy

$app = null

# Facade
auth = {

  # Passport Facebook initialisation setup
  setup: (passport, app) ->

    $app = app

    found = (accessToken, refreshToken, profile, done) =>
      process.nextTick () =>
        facebookId = profile.id

        @api().get('user').findOrCreate({
          socialId   : facebookId
          socialType : 'facebook'
        }, {
          name       : profile._json.name
          social     : profile._raw
        })
        .success (user, created) ->
          if created
            console.log 'New user (Facebook) is created'
          else
            console.log 'User (Facebook) already exists'
          done null, user.values
        .error (err) ->
          console.log(err)

    fbStrategy = new FacebookStrategy {
      clientID     : "365763990235552"
      clientSecret : "af255f55ff7faf901fc6d323f052447b"
      callbackURL  : 'http://localhost:8005/auth/facebook/callback'
    }, found

    passport.use fbStrategy

    # Expose auth endpoint
    $app.get '/auth/facebook', passport.authenticate('facebook'), (req, res) ->
      # noop

    # Auth callback
    $app.get '/auth/facebook/callback', passport.authenticate('facebook', {
      failureRedirect: '/login'
    }), (req, res) ->
      res.redirect '/'

  api: () ->
    $app.get('api')

}





# Exports
module.exports = auth
