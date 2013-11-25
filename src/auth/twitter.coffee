# Import passport-twitter
TwitterStrategy = require('passport-twitter').Strategy

$app = null

# Facade
auth = {

  # Passport Twitter initialisation setup
  setup: (passport, app) ->

    $app = app

    found = (token, tokenSecret, profile, done) =>
      process.nextTick () =>
        twitterId = profile.id

        @api().$get('user').findOrCreate({
          socialId   : twitterId
          socialType : 'twitter'
        }, {
          name       : profile._json.name
          social     : profile._raw
        })
        .success (user, created) ->
          if created
            console.log 'New user (Twitter) is created'
          else
            console.log 'User (Twitter) already exists'
          done null, user.values
        .error (err) ->
          console.log(err)

    twtrStrategy = new TwitterStrategy {
      consumerKey    : 'HMVdy6Hzda83W7wXAjYCSQ'
      consumerSecret : 'WYXgCR0GXfdwBqAlxRiT4qHiq2DiUyGZ2NAC9K7mCQ'
      callbackURL    : 'http://localhost:8005/auth/twitter/callback'
    }, found

    passport.use twtrStrategy

    # Expose auth endpoint
    $app.get '/auth/twitter', passport.authenticate('twitter'), (req, res) ->
      # noop

    # Auth callback
    $app.get '/auth/twitter/callback', passport.authenticate('twitter', {
      failureRedirect: '/login'
    }), (req, res) ->
      res.redirect '/'

  api: () ->
    $app.get('api')

}





# Exports
module.exports = auth
