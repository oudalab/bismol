#trying to monitor twitter, looking for percent of tweet with geo tag info

import tweepy
# note that you need to have an auth.py file for this to run
import auth
# importing time to allow script to run for certain time
import time
# using pickle to save stuff
import pickle

consumer_key = auth.consumer_key
consumer_secret = auth.consumer_secret
access_token = auth.access_token
access_token_secret = auth.access_token_secret

    

#must make a class that impliments the stream listening behavior
class generic_listener(tweepy.StreamListener):

    def __init__(self): 
        tweepy.StreamListener.__init__(self)
        self.total = 0
        self.tagged = 0
        # this is the dial for how long to run. units are seconds.
        self.runtime = 3600
        self.t = time.time()
        self.data = {}

    def on_status(self, status):
        #print status.text
        self.total += 1
        if status.coordinates is not None:
            self.tagged += 1
            self.data[status.id] = status
        #if self.total % 10 == 0:
           # print (self.tagged * 1.0 / self.total * 100.0)
        if time.time() - self.t > self.runtime:
            print self.total, self.tagged, self.tagged * 1.0 / self.total * 100.0
            pickle.dump(self.data, open('statuses.p', 'wb'))
            return False

if __name__ == '__main__':
    #first, authorize with tweepy
    auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
    auth.set_access_token(access_token, access_token_secret)
    api = tweepy.API(auth)
    
    ml = generic_listener()
    stream = tweepy.Stream(auth = api.auth, listener=ml)

    # using this as a hack to get global tweets in english
    #stream.filter(languages=["en"], locations=[-180,-90,180,90])
    
    # use this to track oklahoma tweets
    stream.filter(locations=[-99.98,33.56,-94.43,37.01] )
    # when run at 7:15 am on Feb11,2016, this yielded:
    # 2212 tweets, 302 tagged, 13.6528028933%
    
    # use this to track health keywords
    #stream.filter(track=['diabetes'])

