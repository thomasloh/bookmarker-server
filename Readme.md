

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

✓ Chrome extension app

Light web app
 - Angular.js
 - Social count poller
 - Float label (novel ux concepts)

FUNCTIONALS
------------------
✓ Chrome extension app
- ✓ Able to sign in
- ✓ Able to save bookmark and store in db

Web app
- ✓ Able to sign in / sign out
- ✓ Able to show all bookmarks by a user
- ✓ Able to delete bookmark
- ✓ [Behavioral] Able to open a bookmark ("deleting" the bookmark)
- ✓ Able to show social activities of a bookmark (requires social poller)
- ✓ The higher the social count the darker the number
- Bookmarks saved self-destruct in 24 hours
  - the closer its dying the less opaque it is
- Notification mechanism
- Moving background on login screen. video.js
- About / Help

STYLING
------------------

sidebar.io style

Landing page

Blog

FAQ

Branding
 - 99designs logo contest

Chrome extension app
- Save on success notifier
- Error notifier
- Browser icon logo

Web app
- green, light
- white
- round
- minimalistic
- fast
- no images
- typography and white spaces to give focus to links/bookmarks


MISC
------------------
Mobile version
Https
Sign up, email verification



Deploy
 - Digital Ocean-


 <!-- Future -->

 - Remove polling and switch to long polling

Google plus integrations

 Caching mechanism

 Message Queue

 More tests


<!-- TODO -->

separate web app, chrome ext and rest server into 3 git projects



Possible features

Realtime bookmark clicking notify all clients - websockets


Testing on API
Write tests for counts/analytics
Secure/separate out restAPI API Token


TODO:

