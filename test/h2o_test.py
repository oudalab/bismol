# goal here is to get h2o running
# going to be using softmax regressions
import pickle
import h2o
import numpy
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.feature_extraction.text import TfidfTransformer

#first load the tweets
tweets = pickle.load(open("data/TT-classification/tweets.p", 'rb'))

corpus = []
tags = []
for key,tweet_list in tweets.iteritems():
    for tweet in tweet_list:
        corpus.append(tweet)
        tags.append(key)

# gonna use sk learn to tfidf vecotrize them because h2o actually sucks
# first, count-vectorize them
vectorizer = CountVectorizer(min_df=0.01, stop_words='english')
# min_df is percentage cutoff. using this to trim features down to 10,000
# becasue loading untrimmed takes forever since tfidf.shape =~ 920,000x100,000
# trimmming yields tfidf =~ 920,000x100
# probably should use better methods, maybe word2vec/doc2vec?

X = vectorizer.fit_transform(corpus)
# now hit them with that tfidf
transformer = TfidfTransformer()
tfidf = transformer.fit_transform(X)
# note that tfidf is a scipy sparse matrix
# gotta zip these together for setting up the h2o estimator
preframe = []
for i,vec in enumerate(tfidf.toarray()):
    preframe.append(numpy.append(vec, tags[i]))
preframe = numpy.array(preframe)

h2o.init()
df = h2o.H2OFrame(preframe)
tweet_cl = h2o.estimators.random_forest.H2ORandomForestEstimator(ntrees=200)
X = df.col_names[:-1] # last collumn has the response
Y = df.col_names[-1]
tweet_cl.train(X, Y, training_frame=df)
