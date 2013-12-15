
# Import modules
assert  = require 'assert'
request = require 'supertest'
Q       = require 'q'
_       = require 'underscore'

# Constants
PREFIX = 'http://localhost:8005/api/v1/'

request = request PREFIX


# Users
describe 'Users', () ->

  describe '(GET) retrieve users when empty', () ->

    it 'should return 200 - [] ', (done) ->

      request
      .get('users/')
      .expect('Content-Type', /json/)
      .expect(200)
      .end(done)

  describe '(POST) create a new user', () ->

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

  describe '(GET) retrieve specific user by id', () ->

    existing_user = {
      name: 'Thomas Loh'
    }

    before (done) ->

      delete_all_users () ->

        request
        .post('users/')
        .send(existing_user)
        .end(done)

    describe 'that exists', () ->

      it 'should return 200 - existing user', (done)->

        request
        .get('users/1/')
        .expect(200)
        .end (err, res) ->
          assert res.body.id == 1
          assert res.body.name == existing_user.name
          done()

    describe 'that does not exists', () ->

      it 'should return 400 - Bad request: User not found', (done) ->

        request
        .get('users/2/')
        .expect(400)
        .end (err, res) ->
          assert res.body.errors.message == 'user not found'
          done()

    after (done) ->

      delete_all_users done


  describe '(GET) retrieves all users', () ->

    before (done) ->

      delete_all_users () ->

        Q
        .all([
          Q.ninvoke(request.post('users/').set('Accept', 'application/json').send({name: 'A'}), 'end')
          Q.ninvoke(request.post('users/').set('Accept', 'application/json').send({name: 'B'}), 'end')
          Q.ninvoke(request.post('users/').set('Accept', 'application/json').send({name: 'C'}), 'end')
          Q.ninvoke(request.post('users/').set('Accept', 'application/json').send({name: 'D'}), 'end')
          Q.ninvoke(request.post('users/').set('Accept', 'application/json').send({name: 'E'}), 'end')
        ])
        .then () ->
          done()

    it 'should return 200 - all users', (done) ->

      request
      .get('users/')
      .expect(200)
      .end (err, res) ->
        assert res.body.length == 5
        done()

    after (done) ->

      delete_all_users done

  describe '(PUT) updates user', () ->

    existing_user = {
      name: 'Thomas Loh'
    }

    before (done) ->

      delete_all_users () ->

        request
        .post('users/')
        .send(existing_user)
        .end(done)

    describe 'that exists', () ->

      it 'should return 200 - updated user', (done) ->

        updated_user = _.extend existing_user, {
          email: 'thomasloh_@hotmail.com'
        }

        request
        .put('users/1/')
        .set('Accept', 'application/json')
        .send(updated_user)
        .expect(200)
        .end (err, res) ->
          assert res.body.email == updated_user.email
          done()

    describe 'that does not exists', () ->

      it 'should return 400 - Bad request: User not found', (done) ->

        request
        .put('users/2/')
        .set('Accept', 'application/json')
        .expect(400)
        .end (err, res) ->
          assert res.body.errors.message == 'user not found'
          done()

    after (done) ->

      delete_all_users done

  describe '#(DELETE) deletes user ', () ->

    existing_user = {
      name: 'Thomas Loh'
    }

    before (done) ->

      delete_all_users () ->

        request
        .post('users/')
        .send(existing_user)
        .end(done)

    describe 'that exists', () ->

      it 'should return 400 - Not allowed', (done) ->

        request
        .del('users/1/')
        .expect 400, done

    describe 'that does not exists', () ->

      it 'should return 400 - Bad request: User not found', (done) ->

        request
        .del('users/2/')
        .expect(400)
        .end (err, res) ->
          assert res.body.errors.message == 'user not found'
          done()

    after (done) ->

      delete_all_users done



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

