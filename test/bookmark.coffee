
# Import modules
assert  = require 'assert'
request = require 'supertest'
Q       = require 'q'
_       = require 'underscore'

# Constants
PREFIX = 'http://localhost:8005/api/v1/'

request = request PREFIX


# Bookmarks
describe 'Bookmarks', () ->

  describe '(GET) retrieve bookmarks when empty', () ->

    it 'should return 200 - [] ', (done) ->

      request
      .get('bookmarks/')
      .expect('Content-Type', /json/)
      .expect(200)
      .end(done)

  describe '(POST) create a new bookmark', () ->

    new_bookmark = {
      url: 'http://www.google.com'
    }

    before (done) ->

      delete_all_bookmarks done

    it 'should return 400 - Not allowed', (done) ->

      request
      .post('bookmarks/')
      .send(new_bookmark)
      .set('Accept', 'application/json')
      .expect('Content-Type', /json/)
      .expect(400, done)

  describe '(GET) retrieve specific bookmark by id', () ->

    existing_bookmark = {
      url: 'http://www.google.com'
    }

    before (done) ->

      delete_all_bookmarks done

    describe 'that does not exists', () ->

      it 'should return 400 - Bad request: Bookmark not found', (done) ->

        request
        .get('bookmarks/2/')
        .expect(400)
        .end (err, res) ->
          assert res.body.errors.message == 'bookmark not found'
          done()

    after (done) ->

      delete_all_bookmarks done


  describe '(GET) retrieves all bookmarks', () ->

    before (done) ->

      delete_all_bookmarks done

    it 'should return 200 - all bookmarks', (done) ->

      request
      .get('bookmarks/')
      .expect(200)
      .end (err, res) ->
        assert res.body.length == 0
        done()

    after (done) ->

      delete_all_bookmarks done

  describe '(PUT) updates bookmark', () ->

    existing_bookmark = {
      url: 'http://www.google.com'
    }

    before (done) ->

      delete_all_bookmarks () ->

        request
        .post('bookmarks/')
        .send(existing_bookmark)
        .end(done)

    describe 'that exists', () ->

      it 'should return 400 - Not allowed', (done) ->

        updated_bookmark = _.extend existing_bookmark, {
          email: 'thomasloh_@hotmail.com'
        }

        request
        .put('bookmarks/1/')
        .set('Accept', 'application/json')
        .send(updated_bookmark)
        .expect(400, done)

    describe 'that does not exists', () ->

      it 'should return 400 - Bad request: Bookmark not found', (done) ->

        request
        .put('bookmarks/2/')
        .set('Accept', 'application/json')
        .expect(400)
        .end (err, res) ->
          assert res.body.errors.message == 'bookmark not found'
          done()

    after (done) ->

      delete_all_bookmarks done

  describe '#(DELETE) deletes bookmark ', () ->

    existing_bookmark = {
      url: 'http://www.google.com'
    }

    before (done) ->

      delete_all_bookmarks () ->

        request
        .post('bookmarks/')
        .send(existing_bookmark)
        .end(done)

    describe 'that exists', () ->

      it 'should return 400 - Not allowed', (done) ->

        request
        .del('bookmarks/1/')
        .expect 400, done

    describe 'that does not exists', () ->

      it 'should return 400 - Bad request: Bookmark not found', (done) ->

        request
        .del('bookmarks/2/')
        .expect(400)
        .end (err, res) ->
          assert res.body.errors.message == 'bookmark not found'
          done()

    after (done) ->

      delete_all_bookmarks done



# Creates bookmark bookmarks
# request {
#   url    : PREFIX + 'bookmarks/1/bookmarks/'
#   method : 'POST'
#   jar    : COOKIE_JAR
#   json   : {
#     url: "https://medium.com/tech-talk/28df31f1be98"
#   }
# }, (error, xhr, resp) ->
#   console.log()
#   console.log xhr.statusCode
#   console.log resp

# request {
#   url    : PREFIX + 'bookmarks/1/bookmarks/1/'
#   method : 'GET'
#   jar    : COOKIE_JAR
#   json   : {
#     facebook: {
#       likes: 58
#     },
#     twitter: {
#       tweets: 10000
#     }
#   }
# }, (error, xhr, resp) ->
#   console.log()
#   console.log xhr.statusCode
#   console.log resp

# # Get bookmarks

# # Get bookmark
# request {
#   url    : PREFIX + 'bookmarks/3/'
#   method : 'GET'
#   jar    : COOKIE_JAR
# }, (error, xhr, resp) ->
#   console.log()
#   console.log xhr.statusCode
#   console.log resp


# Utilities
delete_all_bookmarks = (done) ->
  request
  .del('all/')
  .end(done)

