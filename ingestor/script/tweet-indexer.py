#!/usr/bin/python3
# -*- coding: utf-8 -*-
"""
This code takes as argument a series of twitter.json or twitter.json.gz, reads
the twitter text and decides whether that tweet belongs to the label 'food',
'health', or 'exercise'. The output is a thorn file that contains the id_srt of
the tweet, then three integers integers (either one or zero). The first column
is true if the tweet is a part of food and zero otherwise. The second column is
true if the tweet is a part of health and zero otherwise. The third column is
true if the tweet is a part of exercise and zero otherwise.

Example Usage:
    python3 tweet-indexer.py --files 'tweet*.json*' > tweet-index.thorn

Besure to include quotes around the file glob to avoid expansion on the
commandline.

This code is fast with one file so you could use GNU parallels feed it multiple
files at once. For example: 
    find /storage-pool/ -name tweet*.json* | parallel python3 tweet-indexer.py --files {} | tee output.csv

    Or actually 
    find /storage-pool/ -name tweet*json* | parallel --dry-run --no-notice --verbose --progress python3 tweet-indexer.py --files \'{}\' | tee output.txt
"""

import asyncio
import click
import glob
import gzip
import io
import json
import logging
import nltk
import string

from concurrent.futures import ProcessPoolExecutor
from itertools import chain
from json import JSONDecodeError
from nltk.util import ngrams

logging.basicConfig(format='%(asctime)s %(levelname)s:%(name)s %(message)s', level=logging.DEBUG)

MAX_NGRAM = 5

def build_health(kw_file='key-words.json'):
    """Makes an exhaustive pair of keywords from both lists."""
    with io.open(kw_file, 'r') as my_file:
        kws = json.load(my_file)
        words = ["{} {}".format(a.strip(), b.strip()).lower()
                 for a in kws['column1'] for b in kws['column2']]
        words += kws['diseases']
        return words

def build_food(kw_file='foodlist.txt'):
    """Makes an exhaustive pair of keywords from both lists."""
    with io.open(kw_file, 'r') as myf:
        return [t.strip().lower() for t in myf.readlines()]


def build_exercise(kw_file='exerciselist.txt'):
    """Makes an exhaustive pair of keywords from both lists."""
    with io.open(kw_file, 'r') as myf:
        return [t.strip().lower() for t in myf.readlines()]


# Word sets
HEALTH_SET = {x for x in build_health()}
FOOD_SET = {x for x in build_food()}
EXERCISE_SET = {x for x in build_exercise()}


def classify_tweet(text: str) -> str:
    """
    Takes a string of text and returns a string of integers representing its
    membership.
    """
    food = 0
    exercise = 0
    health = 0

    terms = text.split(' ')
    phrases = chain.from_iterable([
                [' '.join(t) for t in ngrams(terms, k)]
                    for k in range(1, min(MAX_NGRAM, len(terms)))])

    for phrase in phrases:
        if phrase in HEALTH_SET: health = 1 
        if phrase in FOOD_SET: food = 1
        if phrase in EXERCISE_SET: exercise = 1

    #return f"{food}Þ{exercise}Þ{health}"
    return "{},{},{}".format(food,exercise,health)


async def process_file(filename: str):
    """Process the files and print the list to stdout"""
    if filename.endswith('gz'):
        # Is the file compressed
        opener = gzip.open(filename, 'rt', encoding='utf-8')
    else:
        # If not compressed
        opener = io.open(filename, 'r')

    #with io.open(filename, 'r') as tweets:
    with opener as tweets:
        for line in tweets:
            # No empty lines
            if line.strip() in string.whitespace: continue
            try:
                tweet = json.loads(line)
                id_str = tweet['id_str']
                text = tweet['text'].lower()
                # Print the row
                print('{},{}'.format(id_str, classify_tweet(text)))
            except (ValueError, JSONDecodeError):
                # json.decoder.JSONDecoderError:
                logging.error("Bad Twitter format {}".format(line))
            except KeyError:
                if 'limit' not in tweet:
                    # We expected to have a limit
                    logging.error(tweet)

    logging.info("Processed {}".format(filename))


@click.command()
@click.option('--files', default='tweet*json*', help='Specify twitter file glob')
def main(files):
    """Grab the specified tweet files and tweet classifications."""
    tweets = glob.glob(files)
    loop = asyncio.get_event_loop()
    loop.run_until_complete(
            asyncio.gather(*[process_file(x) for x in tweets]))
    loop.close()
    logging.info('Finished')


if __name__ == "__main__":
    main()

