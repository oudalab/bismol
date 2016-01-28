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
		self.job_manager = None


