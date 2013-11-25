
# Import modules
assert  = require 'assert'
request = require 'request'

# Constants
COOKIE = 'connect.sid=s%3AFklGfMW2QC4vq6ikqq08BNqa.crNA0aJi1pI1dhGuN7tgfIY9AyT2ER7MSsBpl7INDDY'
COOKIE_JAR = request.jar()
COOKIE_JAR.add(request.cookie(COOKIE))
PREFIX = 'http://localhost:8005/api/v1/'




# Testing
request {
  url    : PREFIX + 'users/1/bookmarks/'
  method : 'POST'
  jar    : COOKIE_JAR
  json   : {
    url: "http://coffeescript.org/#conditionals"
  }
}, (error, xhr, resp) ->
  console.log()
  console.log xhr.statusCode
  console.log resp


