
# Import modules
assert  = require 'assert'
request = require 'supertest'
should  = require('chai').should()
Q       = require 'q'
_       = require 'underscore'

# Constants
PREFIX = 'http://localhost:8005/api/v1/'

request = request PREFIX

# Globals
user = {
  name: 'Thomas Loh'
}
bookmark = {
  url   : 'http://www.google.com',
  title : 'Google'
}

# UserBookmark
describe 'UserBookmark', () ->

  # Creates a dummy user for each test case
  beforeEach (done) ->

    request
    .post('users/')
    .set('Accept', 'application/json')
    .send(user)
    .end(done);

  # Deletes everything after each test case
  afterEach (done) ->

    delete_all_users_bookmarks done

  # ---------------------------------------------------------------------------
  # Sanity checks
  # ---------------------------------------------------------------------------

  describe '(GET) user that exists', () ->

    it 'should return 200 - the user', (done) ->

      request
      .get('users/1/')
      .expect(200)
      .end (err, res) ->
        assert res.body.name == user.name
        done()

  describe '(GET) user that does not exists', () ->

    it 'should return 400 - Bad request: User not found', (done) ->

      request
      .get('users/2/')
      .expect(400)
      .end (err, res) ->
        assert res.body.errors.message == 'user not found'
        done()


  # ---------------------------------------------------------------------------
  # POST
  # ---------------------------------------------------------------------------

  describe '(POST) create a new user bookmark', () ->

    it 'should return 201 - new user bookmark', (done) ->

      request
      .post('users/1/bookmarks/')
      .send(bookmark)
      .set('Accept', 'application/json')
      .expect('Content-Type', /json/)
      .expect(201)
      .end (err, res) ->
        assert res.body.url == bookmark.url, 'Expecting url to match'
        assert res.body.title == bookmark.title, 'Expecting title to match'
        done()

  # ---------------------------------------------------------------------------
  # DELETE
  # ---------------------------------------------------------------------------

  describe '(DELETE) deleting existing user bookmark', () ->

    it 'should return 204 - No Content', (done) ->

      # Create new user bookmark
      request
      .post('users/1/bookmarks/')
      .set('Accept', 'application/json')
      .send(bookmark)
      .expect(201)
      .end (err, res) ->

        # Delete the create user bookarmk
        request
        .del('users/1/bookmarks/1/')
        .expect(204, done)


  # ---------------------------------------------------------------------------
  # GET
  # ---------------------------------------------------------------------------

  # Single

  describe '(GET) user bookmark', () ->

    # Create new user bookmark
    beforeEach (done) ->

      request
      .post('users/1/bookmarks/')
      .set('Accept', 'application/json')
      .send(bookmark)
      .end(done)

    # Delete user bookmark
    afterEach (done) ->

      request
      .del('users/1/bookmarks/1/')
      .end(done)

    it 'should return the only bookmark for that user', (done) ->

      request
      .get('users/1/bookmarks/')
      .expect(200)
      .end (err, res) ->
        assert _.isArray res.body
        assert res.body.length == 1, 'Expecting only one result in an array'
        assert res.body[0].url == bookmark.url, 'Expecting URL to match'
        assert res.body[0].title == bookmark.title, 'Expecting title to match'
        done()

    it 'should return the correct bookmark when requesting specific bookmark', (done) ->

      request
      .get('users/1/bookmarks/1/')
      .expect(200)
      .end (err, res) ->
        assert _.isObject(res.body), 'Expecting an object'
        assert res.body.url == bookmark.url, 'Expecting URL to match'
        assert res.body.title == bookmark.title, 'Expecting title to match'
        done()

  # Multiple

  describe '(GET) user bookmarks', () ->

    describe '(zero)', () ->

      it 'should return zero bookmarks', (done) ->

        request
        .get('users/1/bookmarks/')
        .end (err, res) ->
          assert _.isArray res.body, 'Expecting array type'
          assert res.body.length == 0, 'Expecting zero results'
          done()

    describe '(1)', () ->

      beforeEach (done) ->

        request
        .post('users/1/bookmarks/')
        .set('Accept', 'application/json')
        .send(bookmark)
        .end(done)

      it 'should return 1 bookmark', (done) ->

        request
        .get('users/1/bookmarks/')
        .end (err, res) ->
          assert _.isArray res.body, 'Expecting array type'
          assert res.body.length == 1, 'Expecting one result'
          done()

      # Delete all user bookmarks
      afterEach (done) ->

        request
        .del('users/1/bookmarks/1/')
        .end(done)

    describe '(10)', () ->

      beforeEach (done) ->

        createRandomBookmark = () ->
          Q.ninvoke(request
          .post('users/1/bookmarks/')
          .set('Accept', 'application/json')
          .send(_.extend(bookmark, {title: 'A', url: 'http://www.' + Math.random() * 1000 + '.com' }))
          , 'end')

        Q
        .all(createRandomBookmark() for [1..10])
        .then () ->
          request
          .get('users/1/bookmarks/')
          .end(done)

      it 'should return 10 bookmarks', (done) ->

        request
        .get('users/1/bookmarks/')
        .end (err, res) ->
          assert _.isArray res.body, 'Expecting array type'
          assert res.body.length == 10, 'Expecting ten results'
          done()

      # Delete all user bookmarks
      afterEach (done) ->

        deleteBookmark = (id) ->
          Q.ninvoke(request
          .del("users/1/bookmarks/#{ id }/")
          , 'end')

        Q
        .all(deleteBookmark(i) for i in [1..10])
        .then () ->
          done()

# ---------------------------------------------------------------------------
# PUT
# ---------------------------------------------------------------------------

  describe '(PUT) updates user bookmark', () ->


    # Create new user bookmark
    beforeEach (done) ->

      request
      .post('users/1/bookmarks/')
      .set('Accept', 'application/json')
      .send(bookmark)
      .end(done)

    # Delete user bookmark
    afterEach (done) ->

      request
      .del('users/1/bookmarks/1/')
      .end(done)

    # Update bookmark
    updated_bookmark = _.extend {}, bookmark, {
      facebook : {
        'likes': 10
      }
    }

    it 'should return Content Type: JSON', (done) ->

      request
      .put('users/1/bookmarks/1/')
      .send(updated_bookmark)
      .set('Accept', 'application/json')
      .expect('Content-Type', /json/, done)

    it 'should return 200 - Success', (done) ->

      request
      .put('users/1/bookmarks/1/')
      .send(updated_bookmark)
      .set('Accept', 'application/json')
      .expect(200, done)

    it 'should return the updated user bookmark', (done) ->

      request
      .put('users/1/bookmarks/1/')
      .send(updated_bookmark)
      .set('Accept', 'application/json')
      .end (err, res) ->
        assert _.isEqual res.body.facebook, updated_bookmark.facebook
        done()

    it 'should return the correct bookmark when requesting specific updated bookmark', (done) ->

      request
      .put('users/1/bookmarks/1/')
      .send(updated_bookmark)
      .set('Accept', 'application/json')
      .end (err, res) ->
        request
        .get('users/1/bookmarks/1/')
        .end (err, res) ->
          assert _.isEqual res.body.facebook, updated_bookmark.facebook
          done()

# Utilities
delete_all_users_bookmarks = (done) ->
  request
  .del('all/')
  .end(done)

