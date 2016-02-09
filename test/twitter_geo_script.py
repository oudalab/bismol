#trying to monitor twitter, looking for percent of tweet with geo tag info

import tweepy
# note that you need to have an auth.py file for this to run
import auth

consumer_key = auth.consumer_key
consumer_secret = auth.consumer_secret
access_token = auth.access_token
access_token_secret = auth.access_token_secret

#must make a class that impliments the stream listening behavior
class generic_listener(tweepy.StreamListener):
	total = 0
	tagged = 0
	def on_status(self, status):
		#print status.text
		self.total += 1
		if status.coordinates is not None:
			self.tagged += 1
		if self.total % 10 == 0:
			print self.tagged * 1.0 / self.total * 100.0

if __name__ == '__main__':
	#first, authorize with tweepy
	auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
	auth.set_access_token(access_token, access_token_secret)
	api = tweepy.API(auth)
	
	ml = generic_listener()
	stream = tweepy.Stream(auth = api.auth, listener=ml)
	
	# using this as a hack to get global tweets
	stream.filter(locations=[-180,-90,180,90])
	
	# use this to track health keywords
	#stream.filter(track=['diabetes'])

