# Import modules
_ = require 'underscore'

# Base model
class BaseModel

  $: () ->
    return @model if @model

  api: () ->
    @app.get 'api'

  pipe: (req, res, callback) ->
    return (results) ->
      if _.isNull results
        res.send 400, null
      else if _.isObject results
        res.json results
      else if _.isArray results
        res.send 200, results
      else
        res.send 400, null

  # Serialize data
  serialize: (o) ->
    social = {
      'facebook' : true
      'twitter'  : true
      'linkedin' : true
      'pinterest': true
      'social'   : true
    }
    obj = {}
    for key, value of o
      if social[key]
        obj[key] = JSON.stringify value
      else
        obj[key] = value

    obj

  # Deserialize data
  deserialize: (o) ->
    social = {
      'facebook' : true
      'twitter'  : true
      'linkedin' : true
      'pinterest': true
      'social'   : true
    }
    obj = {}
    for key, value of o
      if social[key] && _.isString(value)
        obj[key] = JSON.parse value
      else
        obj[key] = value

    obj

  errors: {
    DB_ERROR: (e, res) ->
      if e
        console.log(e)

      res.send 400, {
        errors: e
      }
    NOT_FOUND: (type, res) ->

      res.send 400, {
        errors: {
          message: type + ' not found'
        }
      }
    CUSTOM_MESSAGE: (message, res) ->
      if message
        console.log(message)

      res.send 400, {
        errors: {
          message: message
        }
      }

  }


module.exports = BaseModel
