
module.exports = {

  isValidFacebookData: (s) ->
    o = JSON.parse s
    if typeof o != 'object'
      throw new Error 'Expecting a valid JSON'

    if typeof o.likes != 'number'
      throw new Error 'Expecting a number type for "likes"'

    if o.likes < 0
      throw new Error 'Expecting "likes" to be greater or equal to 0'

    if typeof o.shares != 'number'
      throw new Error 'Expecting a number type for "shares"'

    if o.likes < 0
      throw new Error 'Expecting "shares" to be greater or equal to 0'

  isValidTwitterData: (s) ->
    o = JSON.parse s
    if typeof o != 'object'
      throw new Error 'Expecting a valid JSON'

    if typeof o.tweets != 'number'
      throw new Error 'Expecting a number type for "tweets"'

    if o.tweets < 0
      throw new Error 'Expecting "tweets" to be greater or equal to 0'

  isValidLinkedInData: (s) ->
    o = JSON.parse s
    if typeof o != 'object'
      throw new Error 'Expecting a valid JSON'

    if typeof o.likes != 'number'
      throw new Error 'Expecting a number type for "likes"'

    if o.likes < 0
      throw new Error 'Expecting "likes" to be greater or equal to 0'

    if typeof o.shares != 'number'
      throw new Error 'Expecting a number type for "shares"'

    if o.likes < 0
      throw new Error 'Expecting "shares" to be greater or equal to 0'

  isValidPinterestData: (s) ->
    o = JSON.parse s
    if typeof o != 'object'
      throw new Error 'Expecting a valid JSON'

    if typeof o.pins != 'number'
      throw new Error 'Expecting a number type for "pins"'

    if o.pins < 0
      throw new Error 'Expecting "pins" to be greater or equal to 0'

}
