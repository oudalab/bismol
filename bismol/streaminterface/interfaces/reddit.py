import csv
import inspect

class Reddit:
	def __init__(self):
		self.data = []

	def run(self):
		filename = inspect.stack()[0][1][:-3]
		
		#Get CSV file with this name
		#Loop over CSV
		#For each result map data to message (via Normalizer?)
		#Add message to array
		#return message array
		print filename
