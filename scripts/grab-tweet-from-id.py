#!/usr/bin/python3
# encoding: utf-8

import argparse
import csv
import json
from os import environ
import sys
import tweepy #https://github.com/tweepy/tweepy



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

    parser.add_argument("-f", "--file", dest="idfile",
                        default=sys.stdin,
                        help="Takes a file that contains tweet ids or reads ids from stdin.")


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

    if args.idfile != sys.stdin:
        args.idfile = open(args.idfile, 'r')

    errors = 0
    tweets = 0
    for line in args.idfile:
        status = line.strip().strip('"')
        print("status: {}".format(status), file=sys.stderr)
        try:
            tweet = api.get_status(status)
            rawtweet = json.dumps(tweet._json)
            print(rawtweet)
            tweets += 1
        except tweepy.error.TweepError:
            errors += 1

    print(f"Tweets: {tweets}, Errors: {errors}", file=sys.stderr)
