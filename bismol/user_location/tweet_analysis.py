import json
from geopy.distance import vincenty
from nltk.tokenize import TweetTokenizer
from mapbox import Geocoder
from sklearn.feature_extraction.text import CountVectorizer
# for tfidf stuff
from sklearn.feature_extraction.text import TfidfTransformer
# the actual learner
from sklearn.svm import SVR
from sklearn import cross_validation
import time
import matplotlib.pyplot as plt
import datetime


# this file is such that each line is a json object
tweetfile = 'gina-tweets.json'
limit = 500000
gmaps = googlemaps.Client(key='SECRET_KEY')
mapbox_geo = Geocoder(access_token='MAPBOC_KEY')

# this method makes a database query on text
def get_regular_loc(text):
    if text is not None:
        conn = sqlite3.connect('geonames.sqlite3')
        c = conn.cursor()
        try:
            c.execute("select * from geoname where geonameid in (select geonameid from geoname_fts where geoname_fts match '"+text+"') order by population desc;")
            return c.fetchone()
        except sqlite3.OperationalError:
            return None
    else:
        return None

def search_ngrams(text, limit=3):
    '''tweet-tokenizes text and then searches all ngrams where n is [1,limit]'''
    # check out https://github.com/petewarden/geodict
    tknzr = TweetTokenizer()
    tokens = tknzr.tokenize(text)
    places = []
    for i in range(1,limit+1):
        j = 0
        while j+i <= len(tokens):
            places.append(get_regular_loc(' '.join(tokens[j:j+i])))
            j+=1
    return places

def get_center(coords):
    # coords is a list of 4 points
    xs,ys = zip(*coords)
    return (sum(xs)/len(xs),sum(ys)/len(ys))

def get_dist(p1,p2):
    # gets the distance between 2 points using geopy
    return vincenty(p1,p2).kilometers

def search_google(text):
    result = gmaps.geocode(text)
    if len(result) < 1:
        return None
    else:
        return (result[0]['geometry']['location']['lng'],result[0]['geometry']['location']['lat'])

def search_mapbox_center(text):
    result = mapbox_geo.forward(text).geojson()
    if len(result['features']) < 1:
        return None
    else:
        return (result['features'][0]['center'][0],result['features'][0]['center'][1])

def search_mapbox_region(text):
    result = mapbox_geo.forward(text).geojson()
    if len(result['features']) < 1:
        return None
    else:
        return ((result['features'][0]['bbox'][0],result['features'][0]['bbox'][1]),(result['features'][0]['bbox'][2],result['features'][0]['bbox'][3]))

def get_x_dist(p1,p2):
    return get_dist(p1,(p2[0], p1[1]))

def get_y_dist(p1,p2):
    return get_dist(p1,(p1[0],p2[1]))

def get_mean_dist_and_var(tweet):
    if tweet['user']['location'] is None:
        return None
    result = mapbox_geo.forward(tweet['user']['location']).geojson()
    try:
        if len(result['features']) < 1:
            return None
        user_loc_box = result['features'][0]['bbox']
        user_loc_center = result['features'][0]['center']
        tweet_box = tweet['place']['bounding_box']['coordinates'][0]
        tweet_center = get_center(tweet['place']['bounding_box']['coordinates'][0])
    except:
        return None
    # we just want the horizontal distance here, so we have to manipulate the coordinates a bit
    xdist = get_x_dist(user_loc_center,tweet_center)
    ydist = get_y_dist(user_loc_center,tweet_center)
    total_dist = (xdist**2 + ydist**2)**0.5
    #now for the variations
    user_loc_x_var = (1.0/12) * get_x_dist((user_loc_box[0],user_loc_box[1]),(user_loc_box[2],user_loc_box[3]))**2
    user_loc_y_var = (1.0/12) * get_y_dist((user_loc_box[0],user_loc_box[1]),(user_loc_box[2],user_loc_box[3]))**2
    tweet_x_var = (1.0/12) * get_dist(tweet_box[1],tweet_box[2])**2
    tweet_y_var = (1.0/12) * get_dist(tweet_box[0],tweet_box[1])**2
    total_x_var = user_loc_x_var + tweet_x_var
    total_y_var = user_loc_y_var + tweet_y_var
    total_std_dev = (total_x_var + total_y_var)**0.5

    return total_dist,total_std_dev

def check_user_loc_distance(tweet):
    if tweet['user']['location'] is None:
        return None
    user_loc = search_mapbox_center(tweet['user']['location'])
    if user_loc is None:
        return None
    else:
        return get_dist(user_loc, get_center(tweet['place']['bounding_box']['coordinates'][0]))

# finding the locaitons
tweets = []
counter = 0
distances = []
start = time.time()
with open(tweetfile,'r') as f:
    for line in f.readlines():
        tweets.append(json.loads(line))
        l=get_mean_dist_and_var(tweets[-1])
        print(l)
        distances.append(l)
        counter += 1
        if counter % 599 == 0:
            # sleep until the next 60 second interval
            time.sleep(61-((time.time()-start)%60))
        if counter >= limit: break

# the machine learning stuff
vectorizer = CountVectorizer(min_df=1)
transformer = TfidfTransformer()
corpus = [t['user']['description'] + ' ' + t['user']['location'] for t in tweets if t['user']['description'] is not None and t['user']['location'] is not None]
#use last 10% as test
train = corpus[:int(len(corpus)*.9)]
test = corpus[-int(len(corpus)*.1):]
X = vectorizer.fit_transform(train)
tfidf = transformer.fit_transform(X)
coord1 = [get_center(t['place']['bounding_box']['coordinates'][0])[0] for t in tweets if t['user']['description'] is not None and t['user']['location'] is not None]
coord1_train = coord1[:len(train)]
coord1_test = coord1[len(train):]
clf1 = SVR()
clf1.fit(tfidf, coord1_train)
coord2 = [get_center(t['place']['bounding_box']['coordinates'][0])[1] for t in tweets if t['user']['description'] is not None and t['user']['location'] is not None]
coord2_train = coord2[:len(train)]
coord2_test = coord2[len(train):]
clf2 = SVR()
# use last 10% as test
clf2.fit(tfidf, coord2_train)

s = min([int(t['timestamp_ms']) for t in tweets])/1000
f = max([int(t['timestamp_ms']) for t in tweets])/1000
print('start: {0}\tend{1}'.format(datetime.datetime.fromtimestamp(s),datetime.datetime.fromtimestamp(f)))

found = [d[0] for d in distances if d is not None]
plt.hist(found)
plt.title('Error as Distance From Centers')
plt.xlabel('Value')
plt.ylabel('Frequency')
plt.show()

found = [d[0] for d in distances if d is not None and d[0]<1000]
plt.hist(found)
plt.title('Filtered Error as Distance From Centers')
plt.xlabel('Distance')
plt.ylabel('Frequency')
plt.show()

found = [d[1] for d in distances if d is not None]
plt.hist(found)
plt.title('Error as Standard Deviations Between Regions')
plt.xlabel('Distance')
plt.ylabel('Frequency')
plt.show()

test_transform = transformer.transform(vectorizer.transform(test))
preds = zip(clf1.predict(test_transform),clf2.predict(test_transform))
test_points = list(zip(coord1_test,coord2_test))
errs = [get_dist(p,test_points[i]) for i,p in enumerate(preds)]
plt.hist(errs)
plt.title('Error of Predicted Location by Distance')
plt.xlabel('Distance')
plt.ylabel('Frequency')
plt.show()
#todo plot error histogram,think about filter & histogram,&svr histogram
