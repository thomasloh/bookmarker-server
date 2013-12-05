
# Import modules
assert  = require 'assert'
request = require 'supertest'

# Constants
PREFIX = 'http://localhost:8005/api/v1/'

request = request PREFIX


# Users
describe 'Users', () ->

  describe '(GET) when empty', () ->

    it 'should return 200 - [] ', (done) ->

      request
      .get('users/')
      .expect('Content-Type', /json/)
      .expect(200)
      .end(done)

  describe '(POST) a new user', () ->

    new_user = {
      name: 'Thomas Loh'
    }


    before (done) ->

      delete_all_users done

    it 'should return 201 - new user', (done) ->

      request
      .post('users/')
      .send(new_user)
      .set('Accept', 'application/json')
      .expect('Content-Type', /json/)
      .expect(201)
      .end (err, res) ->
        assert res.body.name == new_user.name
        done()

    it 'should return only one user', (done) ->

      request
      .get('users/')
      .expect(200)
      .end (err, res) ->
        assert res.body.length == 1
        done()

  describe '(GET) existing user', () ->

    existing_user = {
      name: 'Thomas Loh'
    }

    before (done) ->

      delete_all_users () ->

        request
        .post('users/')
        .send(existing_user)
        .end(done)

    it 'should return 200 - existing user', ->

      request
      .get('users/1/')
      .expect(200)
      .end (err, res) ->
        assert res.body.id == 1
        assert res.body.name == existing_user.name





# Creates user bookmarks
# request {
#   url    : PREFIX + 'users/1/bookmarks/'
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
#   url    : PREFIX + 'users/1/bookmarks/1/'
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

# # Get user
# request {
#   url    : PREFIX + 'users/3/'
#   method : 'GET'
#   jar    : COOKIE_JAR
# }, (error, xhr, resp) ->
#   console.log()
#   console.log xhr.statusCode
#   console.log resp


# Utilities
delete_all_users = (done) ->
  request
  .del('all/')
  .end(done)

