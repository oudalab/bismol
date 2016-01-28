class Job(object):
	""" An abstract class representing the structure of a job. Any new 
	kind of classifier worker will take in a specific job which tells 
	it how/what to look for and classify, as well as learn(?)"""
	def __init__(self):
		""" initializes the tags, clasification scheme, and maybe
		learning set?"""
		self.tags = None
		self.classification = None

