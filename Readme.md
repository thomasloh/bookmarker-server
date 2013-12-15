

What?

A bookmarking service that helps users deal with information overload on the web



<!-- API -->



<!-- Resource: bookmark -->

Rep:

{
  id             : String,
  url            : String,
  count          : Number,
  <!-- bookmarkedBy   : Array <UserId>, -->
  <!-- archivedBy     : Array <UserId>, -->
  facebook       : JSON {likes: Number, shares: Number},
  twitter        : JSON {tweets: Number},
  linkedin       : JSON {likes: Number, shares: Number},
  pinterest      : JSON {pins: Number}
}

Public access:

GET    /bookmarks     - Retrieves all bookmarks
GET    /bookmarks/:id - Retrieves a specific bookmark
POST   /bookmarks     - Creates a new bookmark
PUT    /bookmarks/:id - Updates an existing bookmark
DELETE /bookmarks/:id - Deletes an existing bookmark



<!-- Resource: user -->

Rep:

{
  id        : String,
  firstName : String,
  lastName  : String,
  email     : String,
  social    : JSON,
}

Public access:

GET    /users     - Retrieves all users
GET    /users/:id - Retrieves a specific user
POST   /users     - Creates a new user
PUT    /users/:id - Updates an existing user
DELETE /users/:id - Deletes an existing user

GET    /users/:id/bookmarks      - Retrieves all bookmarks of a user
GET    /users/:id/bookmarks/:bid - Get a specific bookmark of a user
POST   /users/:id/bookmarks      - Creates a new bookmark for a user
PUT    /users/:id/bookmarks/:bid - Updates a bookmark of a user
DELETE /users/:id/bookmarks/:bid - Deletes a bookmark of a user


<!-- Relation: UserBookmark -->

Rep:

{
  id           : String,
  user         : <UserId>,
  bookmark     : <BookmarkId>,
  facebook     : JSON {likes: Number, shares: Number},
  twitter      : JSON {tweets: Number},
  linkedin     : JSON {likes: Number, shares: Number},
  pinterest    : JSON {pins: Number},
  archived     : Boolean,
  created      : String,
  lastUpdated  : String
}






<!-- Stack -->


Coffeescript
Express
Mocha, Karma
Redis
Postgres (Sequelize)
RabbitMQ
Passport
Moment
Q


<!-- Modules -->

✓ User authentication (social)
 - Session persistence
 - Facebook & Twitter

✓ Users API

✓ Bookmarks API

✓ UserBookmarks API

✓ Platform Basic Test suite

Chrome app

Light client app
 - Angular.js
 - Social count poller
 - Float label (novel ux concepts)
 - icon melon (https://www.evernote.com/shard/s8/sh/6a551850-1e34-457d-b6d6-065c20fbc248/ed7b199804345f99be0bee375f456843/deep/0/Trapit-(Trapit)-and-Sparrow-and-user-bookmark.coffee---test---leafy.png)

Styling

Branding
 - Logo

Deploy
 - Digital Ocean-


 <!-- Future -->


 Caching mechanism

 Message Queue

 More tests




Possible features

Realtime bookmark clicking notify all clients - websockets


Testing on API
Secure/separate out restAPI API Token


TODO:

