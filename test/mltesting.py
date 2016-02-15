# this script assumes that there is a pickle file:
# data/TT-classification/tweets.p
# with dict structure as follows:
# tweets[topic] = list of tweet text strings that correspond to that topic

# testing stuff
from sklearn import cross_validation
# our primary vectorizer
from sklearn.feature_extraction.text import CountVectorizer
# for tfidf stuff
from sklearn.feature_extraction.text import TfidfTransformer
# the actual learner
from sklearn.svm import SVC
# using to get data object
import pickle
# using this library to create classification list
import itertools

# for now, I'm not going to worry about splitting/ testing
# hopefully I can structure it in a way that makes that easy in the future
if __name__ == '__main__':
    tweets = pickle.load(open("data/TT-classification/tweets.p", 'rb'))

    #here is where to modify for testing
    news_corpus = tweets['news']
    events_corpus = tweets['ongoing_events']
    memes_corpus = tweets['memes']
    com_corpus = tweets['commemoratives']

    # classifications will just be repetitions of the same category
    news_class = list(itertools.repeat('news', len(news_corpus)))
    events_class = list(itertools.repeat('ongoing_events', len(events_corpus)))
    memes_class = list(itertools.repeat('memes', len(memes_corpus)))
    com_class = list(itertools.repeat('commemoratives', len(com_corpus)))

    #adding together for single classification list
    master_corpus = news_corpus + events_corpus + memes_corpus + com_corpus
    master_class = news_class + events_class + memes_class + com_class

    #lets set up the vector models with tf-idf weighting
    # following examples:
    # http://scikit-learn.org/stable/modules/feature_extraction.html#text-feature-extraction
    # http://scikit-learn.org/stable/modules/generated/sklearn.svm.SVC.html#sklearn.svm.SVC.fit
    vectorizer = CountVectorizer(min_df=1)
    X = vectorizer.fit_transform(master_corpus)

    transformer = TfidfTransformer()
    tfidf = transformer.fit_transform(X)

    clf = SVC()
    clf.fit(tfidf, master_class)

    scores = cross_validation.cross_val_score(clf, tfidf, master_class, cv=5)
    print scores
