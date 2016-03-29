# for testing
from sklearn import cross_validation
# our primary vectorizer
from sklearn.feature_extraction.text import CountVectorizer
# for tfidf stuff
from sklearn.feature_extraction.text import TfidfTransformer
# the actual learner
from sklearn.svm import SVC

# messages and stuff
import sys
sys.path.append('..')
'''import bismol
from bismol import streaminterface
from bismol.streaminterface import streammanager
from bismol.streaminterface.streammanager import streammanager'''

import streaminterface
from streaminterface import streammanager
from streaminterface.streammanager import streammanager

from message import Message
from job import Job

class twitter_csv_job(Job):

    def __init__(self):
        self.clf = None
        self.tfidf = None
        self.vectorizer = None

    def training(self, tagset, iterator, **kwargs):
        self.vectorizer =  CountVectorizer(min_df=1)
        documents = []
        test_tags = []

        for message in iterator:
            documents.append(message.text)
            test_tags.append(message.tags)

        X = self.vectorizer.fit_transform(documents)

        transformer = TfidfTransformer()
        self.tfidf = transformer.fit_transform(X)
        self.clf = SVC()
        # note that for this classification task, tags should only be of length 1


        self.clf.fit(self.tfidf, test_tags)

    def run_classifier(self, iterator, stop_condition, **kwargs):
        # for now, this only will test the SKLearn-ed classifier
        msg_list = []
        for message in iterator:
            msg_list.append(message.tags)

        scores = cross_validation.cross_val_score(self.clf, self.tfidf, msg_list, cv=5)
        print scores

        '''the classification should be something like the following:
        classified = []
        while not stop_condition:
            if iterator.has_next():
                next_msg = iterator.next()
                new_vec = self.vectorizer.transform(next_msg.text)
                t = self.tfidf.transform(new_vec)
                classified.append(next_msg, clf.predict(t))
            else:
                #wait here'''


        return scores
