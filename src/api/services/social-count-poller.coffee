
# @name
# Social count poller
# @description
# Polls social data for url


# Modules
validator = require('validator').check
request   = require 'request'
Q         = require 'q'
_         = require 'underscore'


# Constants
FB_URL   = 'http://api.ak.facebook.com/restserver.php'
TWTR_URL = 'http://cdn.api.twitter.com/1/urls/count.json'

# Resources

$facebook = (url) ->

  # Checks
  if !ensure_url
    return Q()

  # Proceed
  d = Q.defer()

  # Http request
  request {

    url : FB_URL

    qs  : {
      'v'       : '1.0'
      'method'  : 'links.getStats'
      'format'  : 'json'
      'urls'    : (if _.isArray(url) then url.join(",") else url)
    }

  }, (err, resp) ->

    # Errors check
    if err
      d.reject err
      return

    # Preprocessing
    _.isString(resp.body) && (resp.body = JSON.parse(resp.body))

    # Success
    if _.isArray(resp.body) and resp.body.length == 1
      d.resolve resp.body[0]
    else
      d.resolve resp.body

  d.promise

$twitter = (url) ->

  # Checks
  if !ensure_url
    return Q()

  # Proceed
  d = Q.defer()

  # Http request
  request {

    url : TWTR_URL

    qs  : {
      'url'     : url
    }

  }, (err, resp) ->

    # Errors check
    if err
      d.reject err
      return

    # Preprocessing
    _.isString(resp.body) && (resp.body = JSON.parse(resp.body))

    # Success
    if _.isArray(resp.body) and resp.body.length == 1
      d.resolve resp.body[0]
    else
      d.resolve resp.body

  d.promise

# Utilities
ensure_url = (url) ->
  try
    validator(url).isUrl()
  catch e
    return false

  true

# Poller facade
SocialCountPoller = {

  twitter: (url) ->
    $twitter url

  facebook: (url) ->
    $facebook url

  linkedin: (url) ->


  pinterest: (url) ->


  google_plus: (url) ->


  reddit: (url) ->

}





module.exports = SocialCountPoller











