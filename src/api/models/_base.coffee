# Import modules



# Base model
class BaseModel

  $: () ->
    return @model if @model

  api: () ->
    @app.get 'api'

  pipe: (req, res, callback) ->
    return (results) ->
      res.json results



module.exports = BaseModel
