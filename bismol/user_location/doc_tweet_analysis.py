# since we weren't able to resolve the tweets from mapbox directly,
# this script performs the latter part of the analysis on the text file
# of the tweet distances and resolutions
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.feature_extraction.text import TfidfTransformer
from sklearn.svm import SVR
from sklearn.pipeline import make_pipeline
from sklearn import cross_validation
from geopy.distance import vincenty
import matplotlib.pyplot as plt
import datetime
import json

with open('tweet_distances.txt','r') as distfile:
    distances = [list((float(x.strip("(),")) if 'None' not in x else None for line in distfile for x in line.split() ))]
with open('gina-tweets.json','r') as tweetfile:
    total_tweets = [json.loads(line) for line in tweetfile]

tweets = total_tweets[:len(distances)]

found_dists = [d for d in distances if d is not None]
found_tweets = [t for i,t in enumerate(tweets) if distances[i] is not None]

# now for some of the numbers
# first the timestamps
timestamps = [int(t['timestamp_ms']) for t in tweets]
s = min(timestamps)/1000
f = max(timestamps)/1000
print('start: {0}\tend{1}'.format(datetime.datetime.fromtimestamp(s),datetime.datetime.fromtimestamp(f)))
# now the ratio of found tweets
print("portion of found tweets: {0}".format(len(found_tweets)/len(total_tweets)))

# now the learning
vectorizer = CountVectorizer(min_df=1,ngram_range=(1,2))
transformer = TfidfTransformer()
clf1 = SVR()
coord1_pipe = make_pipeline(vectorizer,transformer,clf1)
clf2 = SVR()
coord2_pipe = make_pipeline(vectorizer,transformer,clf2)
corpus = [t['user']['description'] + ' ' + t['user']['location'] for t in tweets  if t['user']['description'] is not None and t['user']['location'] is not None ]
train = corpus[:int(len(corpus)*.9)]
test = corpus[-int(len(corpus)*.1):]
coord1 = [get_center(t['place']['bounding_box']['coordinates'][0])[0] for t in tweets if t['user']['description'] is not None and t['user']['location'] is not None]
coord1_train = coord1[:len(train)]
coord1_test = coord1[len(train):]
coord2 = [get_center(t['place']['bounding_box']['coordinates'][0])[1] for t in tweets if t['user']['description'] is not None and t['user']['location'] is not None]
coord2_train = coord2[:len(train)]
coord2_test = coord2[len(train):]

coord1_pipe.fit(train,coord1_train)
coord2_pipe.fit(train,coord2_train)

predicteds = zip(coord1_pipe.predict(test),coord2_pipe.predict(test))
test_points = list(zip(coord1_test,coord2_test))
errs = [get_dist(p,test_points[i]) for i,p in enumerate(predicteds)]

# now for plotting
plt.hist([d[0] for d in found])
plt.title('Error as Distance From Centers from Geocoding')
plt.xlabel('Distance')
plt.ylabel('Frequency')
plt.show()

plt.hist([d[1] for d in found])
plt.title('Resolvability')
plt.xlabel('Distance')
plt.ylabel('Frequency')
plt.show()

plt.hist(errs)
plt.title('Error as Distance From Centers from Regression')
plt.xlabel('Distance')
plt.ylabel('Frequency')
plt.show()
