class Worker(object):
	""" The worker class. Will utilize an implimentation of the Job class
	to define a learning target set."""
	def __init__(self):
		""" should initialize variables, set countdown timer,
		maybe begin learning, get stuff from job class, subscribe
		to input and output sources, and start the job"""
		self.job = None
		self.input_subscription = None
		self.output_subscription = None
		self.status = None
		self.training_subscription = None

	def classify(iterator, stop_condition):
		raise NotImplementedError( "Should have implemented this" )

	def train(**kwargs):
		raise NotImplementedError( "Should have implemented this" )

	def do_work(iterator, stop_condition, **kwargs):
		self.train(**kwargs)
		self.classify(iterator, stop_condition, **kwargs)
