#!/usr/bin/python3
# encoding: utf-8

"""
Usage:
    time python3 grab-tweet-from-chuncked-id.py  \
            --consumerkey TWITTER_CONSUMER_KEY \
            --consumersecret TWITTER_CONSUMER_SECRET \
            --accesstoken TWITTER_ACCESS_TOKEN \
            --accesstokensecret TWITTER_ACCESS_TOKEN_SECRET \
            --file Exerciselist_ids.csv --chunk 100 \
            | tee exercise.tweets.json | jq .text
"""

import argparse
import csv
import json
import sys
import tweepy #https://github.com/tweepy/tweepy

from itertools import takewhile
from itertools import zip_longest
from os import environ
from time import sleep


def grouper(iterable, chunk, fillvalue=None):
    "Collect data into fixed-length chunks or blocks"
    # grouper('ABCDEFG', 3, 'x') --> ABC DEF Gxx"
    args = [iter(iterable)] * chunk
    return zip_longest(*args, fillvalue=fillvalue)



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
    parser.add_argument("-e", "--error_file", dest="errorfile",
                        default="error.log",
                        help="The file lists all the tweets that caused errors")
    parser.add_argument("-c", "--chunk", dest="chunk_size",
                        default=100,
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

    api = tweepy.API(auth, compression=True, wait_on_rate_limit=True,
            retry_count=20, retry_delay=3, retry_errors=[503,130])

    # Open the file to read the tweets from
    if args.idfile != sys.stdin:
        args.idfile = open(args.idfile, 'r')

    # Open the error file
    errorfile = open(args.errorfile, 'a')


    errors = 0
    tweets = 0
    status_gen = (line.strip().strip('"') for line in args.idfile)
    status_chunks = grouper(status_gen, int(args.chunk_size))

    for chunk in status_chunks:

        # Remove trailing 'None' from chunks
        slim_chunk = takewhile(lambda x: x is not None, chunk)

        try:
            # Fetch a list of tweets
            json_tweets = api.statuses_lookup(slim_chunk, include_entities=True)

            # Write each tweet in the list to a file 
            for tweet in json_tweets:
                rawtweet = json.dumps(tweet._json)
                print(rawtweet)
                tweets += 1

        except tweepy.error.TweepError as e:
            print(f"Error cgrant {e.api_code} {e.response} {e.reason}", file=sys.stderr)
            # Write error to log
            print(f"Error cgrant {e.api_code} {e.response} {e.reason}",
                    file=errorfile)
            #errorfile.flush()
            errors += 1
        except Exception as e:
            print("Something really bad happened here...", file=errorfile)

    errorfile.close()
    print(f"Tweets: {tweets}, Errors: {errors}", file=sys.stderr)
