# this is the script that will connect all the pieces.

from twitter_csv_job import twitter_csv_job
from twitter_csv_worker import twitter_csv_worker

tagset = ['news','memes','ongoing_events','commemoratives']
in_file = '/Users/erikholbrook/Documents/science/bismol/test/TT_geo_tweets.csv'

j = twitter_csv_job()
w = twitter_csv_worker(j, tagset=tagset, input_file=in_file, output_type='pika', train_file=in_file)

w.train()
w.classify()
