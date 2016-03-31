import sys

sys.path.append('..')
'''import bismol
from bismol import streaminterface
from bismol.streaminterface import streammanager
from bismol.streaminterface.streammanager import streammanager'''
import streaminterface
from streaminterface import streammanager
from streaminterface.streammanager import streammanager

import urllib
from urllib import request

from worker import Worker

class twitter_csv_worker(Worker):
    """ Implementation of the worker object for using SKlearn with message
    objects"""
    def __init__(self, job, input_file,interface ='TT', tagset=None, output_type=None, train_file=None,*args, **kwargs):
        # initialize variables
        self.interface = interface
        self.tagset = tagset
        self.job = job
        self.input_subscription = input_file
        self.output_subscription = output_type
        self.training_subscription = train_file
        self.status = None


    def classify(self, iterator=None, sc=None):
        if iterator is None:
            iterator = streammanager(self.interface,self.input_subscription)
        # classified will be able to be used to push output to output_subscription
        classified = self.job.run_classifier(iterator, stop_condition = sc)
        self.output(classified)

    def train(self, **kwargs):
        self.job.training(self.tagset, streammanager(self.interface,self.training_subscription), **kwargs)

    def output(self, classified, *args, **kwargs):
        # output to pika queue should happen here
        # http://www.rabbitmq.com/tutorials/tutorial-one-python.html
        #connection = pika.BlockingConnection(pika.ConnectionParameters('localhost'))
        #channel = connection.channel()
        #channel.queue_declare(queue='message')
        # TODO
        url = 'localhost:8099/newmessage'
        request.urlopen(url, str(map(lambda x: x.tojson(), classified)), method='POST')
