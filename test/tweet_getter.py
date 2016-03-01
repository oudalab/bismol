import tweepy
# note that you need to have an auth.py file for this to run
import auth as AUTH
# using pickle to save stuff
import pickle
# of course also importing csv to read files
import csv
# compression stuff
import gzip

def get_tweet(api, array, id):
    # note that the api call actually returns an array of length 1,
    #    hence the [0] at the end
    print "getting " + id
    tweet_result = api.statuses_lookup([id])
    # if we got some tweets, put them into the array
    for t in tweet_result:
        array.append(t)

def get_tweets(api, array, file):
    # 2.0 method of above that simplifies and allows multiple calls
    # this will be the queue of ids
    queue = []
    with open(('data/TT-classification/tweets/'+file), 'rb') as tweet_file:
        r2 = csv.reader(tweet_file,delimiter='\t')
        for line in r2:
            # append id
            queue.append(line[0])
            if len(queue) == 100:
                tweet_result = api.statuses_lookup(queue)
                for t in tweet_result:
                    array.append(t)
                queue = []
        # once the main loop is done, there may be some more tweets left
        if len(queue) > 0:
            tweet_result = api.statuses_lookup(queue)
            for t in tweet_result:
                array.append(t)
            queue = []

if __name__ == '__main__':
    auth = tweepy.OAuthHandler(AUTH.consumer_key, AUTH.consumer_secret)
    auth.set_access_token(AUTH.access_token, AUTH.access_token_secret)
    api = tweepy.API(auth, wait_on_rate_limit=True, wait_on_rate_limit_notify=True)

    # our 4 arrays that will store the tweets
    news = []
    ongoing_events = []
    memes = []
    commemoratives = []

    #using a pseudo queue to (hopefully) speed up requests and avoid timeouts

    #open twitter annotations file to get twitter hashes
    #note that this file is gitignored for security reasons
    with open('data/TT-classification/TT-annotations.csv', 'rb') as file:
        r = csv.reader(file,delimiter=';')
        for row in r:
            print "processing topic: " + row[2]
            # row has format: hash, date, topic, classification
            # so row[0] will allow us to look up tweet ids
            if row[3] == "news":
                # call getting method with news array
                try:
                    get_tweets(api, news, row[0])
                except:
                    break

            elif row[3] == "ongoing-event":
                # call with o_e array
                try:
                    get_tweets(api, ongoing_events, row[0])
                except:
                    break

            elif row[3] == "meme":
                # similar to above
                try:
                    get_tweets(api, memes, row[0])
                except:
                    break

            elif row[3] == "commemorative":
                # not even bothering with this one
                try:
                    get_tweets(api, commemoratives, row[0])
                except:
                    break

    # now that we have everything, lets store it as a pickle
    tweets = {}
    tweets['news'] = news
    tweets['ongoing_events'] = ongoing_events
    tweets['memes'] = memes
    tweets['commemoratives'] = commemoratives
    pickle.dump(tweets, gzip.open("data/TT-classification/tweets.p", 'wb'))
