import csv
import pickle
import gzip

#this converts the output of the tweet_gettter into a csv file
tweets = pickle.load(gzip.open('data/TT-classification/tweets3.gz', 'rb'))

with open('TT_tweets.csv','wb') as csvfile:
    w = csv.writer(csvfile, delimiter='`')
    for key in tweets.keys():
        for tweet in tweets[key]:
            w.writerow([tweet.id, tweet.source_url, tweet.text.encode('utf-8'), tweet.coordinates, tweet.created_at, key])
