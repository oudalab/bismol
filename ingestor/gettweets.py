#!/usr/bin/python3
import argparse
import io
import json
from json import dumps
import logging
import os
from os import environ
import psycopg2
from psycopg2 import extras 
import sys
import tweepy


RUNID = environ['RUNID'] or "DEFAULT"

log = logging.getLogger(RUNID)
log.setLevel(logging.INFO)
ch = logging.StreamHandler()
ch.setLevel(logging.INFO)
formatter = logging.Formatter("%(asctime)s %(levelname)s:%(name)s %(message)s")
ch.setFormatter(formatter)
log.addHandler(ch)

# Twitter API info: https://dev.twitter.com/streaming/overview/request-parameters#track
# Tweepy github: https://github.com/tweepy/tweepy/tree/master/tweepy

# Note: All environment variables should be 
# docker run --env-file twitter.env --env-file database.env
# Usage: python3 gettweets.py | tee -a tweets.json.gz

# Connect to twitter.com/oudalab bismol app

INSERT = """INSERT INTO tweets (tweetid, runid, status, statusvec, tweet)
            VALUES (%s, %s, %s, to_tsvector('english', %s), %s)"""

class HealthStreamListener(tweepy.StreamListener):

    def __init__(self, api=None):
        # Connect to the DB
        self.conn = psycopg2.connect("host ='{PGHOST}' dbname='{PGDATABASE}' "
            "user='{PGUSER}' password='{PGPASSWORD}' port='{PGPORT}'"
            .format(**environ))
        super(HealthStreamListener, self).__init__(api) # Python 3

    def on_status(self, status):
        # Insert the data into postgresql
        cur = self.conn.cursor()
        cur.execute(INSERT, (status.id, RUNID, status.text, status.text, extras.Json(status._json)))
        self.conn.commit()
        cur.close()
        print('{}'.format(dumps(status._json)), file=sys.stderr)

    def on_error(self, status_code):
        # Close database connection
        self.conn.close()
        if status_code == 420:
            #returning False in on_data disconnects the stream
            return False

# Get the twitter key words
def get_keywords(kw_file = 'key-words.json'):
    with io.open(kw_file, 'r') as f:
        kw = json.load(f)
        words = ["{} {}".format(a,b) for a in kw['column1'] for b in kw['column2']]
        words += kw['diseases']
        return words


if __name__ == "__main__":
    # Run as a script
    parser = argparse.ArgumentParser()
    parser.add_argument("-ck", "--consumerkey", dest="ck",
                        default=environ['TWITTER_CONSUMER_KEY'],
                        help="The twitter consumer key")
    parser.add_argument("-cs", "--consumersecret", dest="cs",
                        default=environ['TWITTER_CONSUMER_SECRET'],
                        help="The twitter consumer secret")
    parser.add_argument("-at", "--accesstoken", dest="at",
                        default=environ['TWITTER_ACCESS_TOKEN'],
                        help="The twitter access token")
    parser.add_argument("-ats", "--accesstokensecret", dest="ats",
                        default=environ['TWITTER_ACCESS_TOKEN_SECRET'],
                        help="The twitter access token secret")

    args = parser.parse_args()

    auth = tweepy.OAuthHandler(args.ck, args.cs)
    auth.set_access_token(args.at, args.ats)

    api = tweepy.API(auth, compression=True, wait_on_rate_limit=True)

    myStreamListener = HealthStreamListener(api)
    myStream = tweepy.Stream(auth = api.auth, listener=myStreamListener)
    #myStream.filter(track=['diabetes'], async=True)
    myStream.filter(track=get_keywords(), async=True)

