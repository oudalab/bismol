# this is the script that will connect all the pieces.
import sys
sys.path.append('..')
import bismol
from bismol.magic import twitter_csv_job
from bismol.magic import twitter_csv_worker

tagset = ['news','memes','ongoing_events','commemoratives']
in_file = 'TT_geo_tweets.csv'

j = twitter_csv_job()
w = twitter_csv_worker(j, tagset=tagset, input_file=in_file)

w.train()
w.classify()
