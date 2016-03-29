import sys
sys.path.append('..')
'''import bismol
from bismol import streaminterface
from bismol.streaminterface import streammanager
from bismol.streaminterface.streammanager import streammanager'''
import streaminterface
from streaminterface import streammanager
from streaminterface.streammanager import streammanager

from worker import Worker

class twitter_csv_worker(Worker):
    """ Implementation of the worker object for using SKlearn with message
    objects"""
    def __init__(self, job, input_file,interface ='TT', tagset=None, output_file=None, train_file=None):
        # initialize variables
        self.interface = interface
        self.tagset = tagset
        self.job = job
        self.input_subscription = input_file
        self.output_subscription = output_file
        self.training_subscription = train_file
        self.status = None


    def classify(self, iterator=None, sc=None):
        if iterator is None:
            iterator = streammanager(self.interface,self.input_subscription)
        # classified will be able to be used to push output to output_subscription
        classified = self.job.run_classifier(iterator, stop_condition = sc)

    def train(self, **kwargs):
        self.job.training(self.tagset, streammanager(self.interface,self.training_subscription), **kwargs)
