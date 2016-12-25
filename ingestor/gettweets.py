#!/usr/bin/python3
"""This script takes uses the twitter stream and keywords to
pull in tweets."""

import argparse
import io
import json
from json import dumps
from os import environ
import sys
import time
import tweepy


RUNID = environ.get('RUNID') or "DEFAULT"
FILENAME = environ.get('TWEET_FILE') or \
        '/data/tweetsdb/tweet_health_{}.json'.format(time.strftime("%Y%m%d%H%M%S"))


# Twitter API info:
#  https://dev.twitter.com/streaming/overview/request-parameters#track
# Tweepy github: https://github.com/tweepy/tweepy/tree/master/tweepy

# Note: All environment variables should be
# docker run --env-file twitter.env --env-file database.env
# Usage: python3 gettweets.py | tee -a tweets.json.gz

# Connect to twitter.com/oudalab bismol app


class HealthStreamListener(tweepy.StreamListener):
    """Extended Steam listener for these health tweets."""

    # def __init__(self,api=None):
    def __init__(self, api):
        super(HealthStreamListener, self).__init__(api)  # Python 3
        self.twfile = io.open(FILENAME, 'w', encoding="utf-8")
        print('__init__ {}'.format(FILENAME), file=sys.stderr)

    def on_status(self, status):
        """This is depreciated and not actually used anymore"""
        # print('{}'.format(dumps(status._json)), file=sys.stderr)
        print('{}'.format(dumps(status._json)), file=self.twfile)
        sys.stderr.write('.')

    def on_data(self, raw_data):
        print('{}'.format(raw_data), file=self.twfile)
        return True

    def on_error(self, status_code):
        if status_code == 420:
            # returning False in on_data disconnects the stream
            print('Caught an error :-({}'.format(status_code), file=sys.stderr)
            return False
        else:
            print('Caught an error :-({}'.format(status_code), file=sys.stderr)
            return True


# Get the twitter key words
def get_keywords(kw_file='key-words.json'):
    """Makes an an exhaustive pair of keywords from both lists."""
    with io.open(kw_file, 'r') as my_file:
        kws = json.load(my_file)
        words = ["{} {}".format(a.strip(), b.strip())
                 for a in kws['column1'] for b in kws['column2']]
        words += kws['diseases']
        return words


if __name__ == "__main__":
    # Run as a script
    parser = argparse.ArgumentParser()
    parser.add_argument("-ck", "--consumerkey", dest="ck",
                        default=environ.get('TWITTER_CONSUMER_KEY'),
                        help="The twitter consumer key")
    parser.add_argument("-cs", "--consumersecret", dest="cs",
                        default=environ.get('TWITTER_CONSUMER_SECRET'),
                        help="The twitter consumer secret")
    parser.add_argument("-at", "--accesstoken", dest="at",
                        default=environ.get('TWITTER_ACCESS_TOKEN'),
                        help="The twitter access token")
    parser.add_argument("-ats", "--accesstokensecret", dest="ats",
                        default=environ.get('TWITTER_ACCESS_TOKEN_SECRET'),
                        help="The twitter access token secret")

    # Option to be flexibe with time outs and ssl errors
    # https://github.com/ryanmcgrath/twython/issues/273
    client_args = {'verify': False}

    args = parser.parse_args()

    if None in (args.ck, args.at, args.cs, args.ats):
        print("Error defining environment variables", file=sys.stderr)
        sys.exit()

    auth = tweepy.OAuthHandler(args.ck.strip(), args.cs.strip())
    auth.set_access_token(args.at.strip(), args.ats.strip())

    api = tweepy.API(auth, compression=True, wait_on_rate_limit=True)

    myStreamListener = HealthStreamListener(api)
    myStream = tweepy.Stream(auth=api.auth, listener=myStreamListener)

    print("Keywords:\n{}".format(get_keywords()), file=sys.stderr)

    # English only tweets
    languages = ["en"]
    # US Bounding box
    # locations = [-125.4113785028, 24.686952412,
    #             -65.91796875, 49.382372787]
    # Run the stream continually, try again on failure
    while True:
        try:
            myStream.filter(track=get_keywords(),
                            languages=languages,
                            # locations=locations,
                            async=True)
        except Exception as e:
            continue
