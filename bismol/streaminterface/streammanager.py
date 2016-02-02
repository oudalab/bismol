import csv
import os
import json
import pandas

#from normalizer import Normalizer
######fix import so I can import message from parent directory######

"""This file is the main 'runner' of the data. It takes all the data sources and interface files, takes their data, normalizes it and puts it in a message object and sends it."""
if __name__ == "__main__":

	#Get the path of the interfaces
	filePath = os.path.join(os.getcwd(), "interfaces")

	#Loop over each interface file in the directory
	for interface in os.listdir(filePath):

		#Make sure we are looking at just JSON files
		if interface[-4:] == "json":

			#Get the name of the data file we want
			nameOfFile = interface[:-5] + ".csv"

			#get the paths for the config file and the data file
			configPath = os.path.join(filePath, interface)
			dataPath =  os.path.join(os.path.dirname(os.path.dirname(filePath)), "data", nameOfFile)
			
			#Create an object to easily access the data
			pandasobj = pandas.read_csv(dataPath)

			#Loop over each row of the data
			for i, row in enumerate(pandasobj.values):

				#print i, row

				#Create our message object
				#message = Message()

				#Load up our Json file into an object
				mappingObject =  json.load(open(configPath))

				#Set the source of the message -- will be the same for every interface
				#message.source = mappingObject["name"]

				#Loop over each mapping attribute, getting both the key and value
				for mapping in mappingObject["mapping"]:
					for key, value in mapping.iteritems():

						#Set the appropriate field on the message object to our normalized value from the csv row
						#setattr(message, value, normalize(pandasobj.value(key), value))
						print key, value

				#So now our message is complete so send it off
				#message.send()
