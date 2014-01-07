
# A queue for processing social count updates/writes


# Modules
_ = require 'underscore'

# Internals
$app    = null
$store  = []
$poller = null



# Utilities
_save = (ub, bookmark, type, data) ->

  # Update bookmark
  if bookmark.values[type]
    bs = JSON.parse bookmark.values[type]
    for key of data.current
      if _.isNumber(+data.current[key]) and _.isNumber(+bs.current[key])
        if +data.current[key] > +bs.current[key]
          bs.current[key] = +data.current[key]
  else
    bs = data

  i = {}
  i[type] = JSON.stringify bs

  bookmark
  .updateAttributes(i)
  .error (e) ->
    console.log('Problem saving social data to bookmark')
    console.log(e)

  # Update user bookmark
  if ub.values[type]
    ubs = JSON.parse ub.values[type]
    for key of data.current
      if _.isNumber(+data.current[key]) and _.isNumber(+ubs.current[key])
        if +data.current[key] > +ubs.current[key]
          ubs.current[key] = +data.current[key]
  else
    ubs = data

  o = {}
  o[type] = JSON.stringify ubs

  ub
  .updateAttributes _.extend o, {
    updatedAt  : moment(Date.now()).utc().format()
  }
  .error (e) ->
    console.log('Problem saving social data to user bookmark')
    console.log(e)


Queue = {

  setup: (app) ->

    $app = app

    $poller = $app.get('api').services.social_count_poller

    # Start loop
    setInterval @process, 1000

  api: () ->
    $app.get 'api'

  process: () ->

    while $store.length

      item = $store.shift()

      do (target = item, $p = $poller, $s = _save) ->

        process.nextTick () =>

          bookmark      = target.bookmark
          user_bookmark = target.user_bookmark

          if bookmark and user_bookmark
            $p
            .facebook(bookmark.values.url)
            .fail(console.log)
            .then (data) ->
              $s user_bookmark, bookmark, 'facebook', {
                bookmarked: data
                current   : data
              }
            $p
            .twitter(bookmark.values.url)
            .fail(console.log)
            .then (data) ->
              $s user_bookmark, bookmark, 'twitter', {
                bookmarked: data
                current   : data
              }

  push: (item) ->
    $store.push item

  save: _save


}


module.exports = Queue
