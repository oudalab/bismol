import sys
sys.path.append('..')
import bismol
from bismol import streaminterface
from bismol.streaminterface import streammanager
from bismol.streaminterface.streammanager import streammanager

class twitter_csv_worker(Worker):
    """ Implementation of the worker object for using SKlearn with message
    objects"""
    def __init__(self, input_file, output_file, train_file, job):
        # initialize variables
        self.interface = "TT"
        self.tagset = ['news','ongoing_events','memes','commemoratives']
        self.job = job
        self.input_subscription = input_file
        self.output_subscription = output_file
        self.training_subscription = train_file
        self.status = None

    def classify(iterator=streammanager(self.interface,input_file), sc):
        # classified will be able to be used to push output to output_subscription
        classified = self.job.run_classifier(iterator, stop_condition = sc)

    def train(**kwargs):
        self.job.training(self.tagset, streammanager(self.interface,train_file))
