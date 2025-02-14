# livemusicbot

A reddit bot for posting today's gigs

## Usage

```
./livemusicbot.rb
```

Fetches all of today's gigs for Melbourne using the Live Music Locator API
<https://api.lml.live>, and posts them to Reddit. If there are no gigs for
today, the program exits and goes to the pub.

I've set up a bot account u/livemusicbot to post the gigs, and a subreddit
r/livemusicmelbourne to post them to. This script needs to authenticate as
u/livemusicbot. To do this, you need to create a .env file in the same
directory as the script with the following contents:

```
REDDIT_CLIENT_ID=client_id
REDDIT_CLIENT_SECRET=client_secret
REDDIT_USERNAME=livemusicbot
REDDIT_PASSWORD=secretpassword
```

Once you've done that, it *should* just work.
