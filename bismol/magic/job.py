class Job(object):
	""" An abstract class representing the structure of a job. Any new
	kind of classifier worker will take in a specific job which tells
	it how/what to look for and classify, and train"""

	def training(tagset, iterator, 	**kwargs):
		""" method to train classifier. args should include an iterator."""
		raise NotImplementedError( "Should have implemented this" )

	def run_classifier(iterator, stop_condition, **kwargs):
		"""method that iterates over, and waits if iterator momentarily
		does't have values. it keeps going until stop_condition is met.

		this should return an iterator of classified stuff."""
		raise NotImplementedError( "Should have implemented this" )
