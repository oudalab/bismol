# for testing
from sklearn import cross_validation
# our primary vectorizer
from sklearn.feature_extraction.text import CountVectorizer
# for tfidf stuff
from sklearn.feature_extraction.text import TfidfTransformer
# the actual learner
from sklearn.svm import SVC

# messages and stuff
import message
import sys
sys.path.append('..')
import bismol
from bismol import streaminterface
from bismol.streaminterface import streammanager
from bismol.streaminterface.streammanager import streammanager

class twitter_csv_job(Job):

    def __init__(self):
        self.clf = None
        self.tfidf = None

    def training(tagset, iterator, **kwargs):
        vectorizer =  CountVectorizer(min_df=1)
        X = vectorizer.fit_transform([message.text for message in iterator])

        transformer = TfidfTransformer()
        self.tfidf = transformer.fit_transform(X)
        self.clf = SVC()
        # note that for this classification task, tags should only be of length 1
        clf.fit(tfidf, [message.tags[0] for message in iterator])

    def run_classifier(iterator, stop_condition, **kwargs):
        # for now, this only will test the SKLearn-ed classifier
        scores = cross_validation.cross_val_score(self.clf, self.tfidf, [message.text for message in iterator], cv=5)
        print scores
