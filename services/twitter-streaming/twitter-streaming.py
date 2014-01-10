# Import modules
from twython import Twython, TwythonStreamer

# Obtain OAuth 2 access token
APP_KEY    = 'HMVdy6Hzda83W7wXAjYCSQ'
APP_SECRET = 'WYXgCR0GXfdwBqAlxRiT4qHiq2DiUyGZ2NAC9K7mCQ'

# Save access token
twitter = Twython(APP_KEY, APP_SECRET)
auth    = twitter.get_authentication_tokens(callback_url='http://127.0.0.1:8005/auth/twitter/callback')

# OAUTH_TOKEN = auth['oauth_token']
# OAUTH_TOKEN_SECRET = auth['oauth_token_secret']
OAUTH_TOKEN = '69827057-IKiuO83FSEDrvMOmnA1ZlSccuxJW5vuYN5v8CfRqk'
OAUTH_TOKEN_SECRET = '4piR82MRbW4hZSMDk0UE5q6XUumfhv3nN6JlHFdbWQXvx'
print OAUTH_TOKEN
print OAUTH_TOKEN_SECRET

# twitter = Twython(APP_KEY, APP_SECRET, OAUTH_TOKEN, OAUTH_TOKEN_SECRET)
# print twitter.search(q = 'python')

class TwitterStreamer(TwythonStreamer):

  def on_success(self, data):
    print 'Success!'
    if 'text' in data:
      print data['text'].encode('utf-8')

  def on_error(self, status_code, data):
    print 'Error!'
    print status_code

  def on_timeout():
    print 'Timing out!'


stream = TwitterStreamer(APP_KEY, APP_SECRET, OAUTH_TOKEN, OAUTH_TOKEN_SECRET)
# stream.statuses.filter(locations='-122.75,36.8,-121.75,37.8')
stream.statuses.filter(track='#js')


