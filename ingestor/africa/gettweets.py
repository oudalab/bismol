#!/usr/bin/python3
"""This script takes uses the twitter stream and keywords to
pull in tweets."""

import argparse
import gzip
from json import dumps
from os import environ
import sys
import time
import tweepy


RUNID = environ.get('RUNID') or "USADEFAULT"
FILENAME = environ.get('TWEET_FILE') or \
        '/data/tweetsdb/tweet_africa_{}.json.gz'.format(time.strftime("%Y%m%d%H%M%S"))


# Twitter API info:
#  https://dev.twitter.com/streaming/overview/request-parameters#track
# Tweepy github: https://github.com/tweepy/tweepy/tree/master/tweepy

# Note: All environment variables should be
# docker run --env-file twitter.env --env-file database.env
# Usage: python3 gettweets.py | tee -a tweets.json.gz

# Connect to twitter.com/oudalab bismol app


class AfricaStreamListener(tweepy.StreamListener):
    """Extended Steam listener for these food tweets."""

    # def __init__(self,api=None):
    def __init__(self, api):
        super(AfricaStreamListener, self).__init__(api)  # Python 3
        self.twfile = gzip.open(FILENAME, 'wt', encoding="utf-8")
        print('__init__ {}'.format(FILENAME), file=sys.stderr)

    def on_status(self, status):
        """This is depreciated and not actually used anymore"""
        # print('{}'.format(dumps(status._json)), file=sys.stderr)
        # print('{}'.format(dumps(status._json)), file=self.twfile)
        self.twfile.write('{}\n'.format(dumps(status._json)))
        self.flush()
        # sys.stderr.write('.')

    def on_data(self, raw_data):
        #print('{}'.format(raw_data), file=self.twfile)
        self.twfile.write('{}\n'.format(raw_data))
        self.flush()
        return True

    def on_error(self, status_code):
        if status_code == 420:
            # returning False in on_data disconnects the stream
            print('Caught an error :-({}'.format(status_code), file=sys.stderr)
            return False
        else:
            print('Caught an error :-({}'.format(status_code), file=sys.stderr)
            return True


# Run the program
def start(args):
    """Run the whole food scraper program block by block"""

    if None in (args.ck, args.at, args.cs, args.ats):
        print("Error defining environment variables, {}".format(args), file=sys.stderr)
        sys.exit()

    
    args.ind = int(args.ind)
    args.b = int(args.b)

    auth = tweepy.OAuthHandler(args.ck.strip(), args.cs.strip())
    auth.set_access_token(args.at.strip(), args.ats.strip())

    api = tweepy.API(auth, compression=True, wait_on_rate_limit=True)

    mystreamlistener = AfricaStreamListener(api)
    mystream = tweepy.Stream(auth=api.auth, listener=mystreamlistener)

    # English only tweets
    languages = ["en"]
    # US Bounding box
    locations = [-125.4113785028, 24.686952412, -65.91796875, 49.382372787]
    # Run the stream continually, try again on failure
    while True:
        try:
            mystream.filter(languages=languages, locations=locations, async=True)
        except:
            continue


if __name__ == "__main__":
    # Run as a script
    PARSER = argparse.ArgumentParser()
    PARSER.add_argument("-ck", "--consumerkey", dest="ck",
                        default=environ.get('TWITTER_CONSUMER_KEY'),
                        help="The twitter consumer key")
    PARSER.add_argument("-cs", "--consumersecret", dest="cs",
                        default=environ.get('TWITTER_CONSUMER_SECRET'),
                        help="The twitter consumer secret")
    PARSER.add_argument("-at", "--accesstoken", dest="at",
                        default=environ.get('TWITTER_ACCESS_TOKEN'),
                        help="The twitter access token")
    PARSER.add_argument("-ats", "--accesstokensecret", dest="ats",
                        default=environ.get('TWITTER_ACCESS_TOKEN_SECRET'),
                        help="The twitter access token secret")
    PARSER.add_argument("-ind", "--index", dest="ind", type=int,
                        default=environ.get('TWITTER_INDEX') or 1,
                        help="The index to the keyword set to be streamed")

    start(PARSER.parse_args())
