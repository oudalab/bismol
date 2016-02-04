import csv
import os
import json
import sys
import io
import pdb


#hack to fix import
sys.path.append("..")

from bismol.streaminterface.normalizer import normalize
from bismol.message import Message

#Copied from https://docs.python.org/2/library/csv.html
#Required for reading unicode csv
def unicode_csv_reader(unicode_csv_data, dialect=csv.excel, **kwargs):
    # csv.py doesn't do Unicode; encode temporarily as UTF-8:
    csv_reader = csv.reader(utf_8_encoder(unicode_csv_data), dialect=dialect, **kwargs)
    for row in csv_reader:
        # decode UTF-8 back to Unicode, cell by cell:
        yield [unicode(cell, 'utf-8') for cell in row]

def utf_8_encoder(unicode_csv_data):
    for line in unicode_csv_data:
        yield line.encode('utf-8')

"""This is the stream manager generator. It takes a mapping json file (without the file extension) located in the interfaces folder and a data file with the extension that's located in the data directory"""
def streammanager(mapping, dataFile):

	#Get the path of the interface
	filePath = os.path.join(os.getcwd(), "interfaces")

	#get the paths for the config file and the data file
	interfacePath = os.path.join(filePath, mapping + ".json")
	
	#pdb.set_trace()

	#print os.path.dirname(os.path.realpath(__file__))

	dataPath =  os.path.join(os.path.dirname(os.path.dirname(os.path.realpath(__file__))), "data", dataFile)
	
	#Load up our Json file into an object
	mappingObject =  json.load(io.open(interfacePath, encoding="utf-8"), encoding="utf-8")

	#Check if the mapping has a header
	hasHeader = mappingObject["hasHeader"]

	isTSV = mappingObject["isTSV"]

	#Open up our data file and read it
	with io.open(dataPath, encoding="utf-8") as dataFile:
		if isTSV:
			dataReader = unicode_csv_reader(dataFile, delimiter='\t')
		else:
			dataReader = unicode_csv_reader(dataFile)

		#If the object has a header
		if hasHeader:
			#Get the header row
			headerRow = dataReader.next()

			#Create and populate our dictionary mapping header values to index
			headerToIndex = {}
			for mapping in mappingObject["mapping"]:
				for key, value in mapping.iteritems():
					headerToIndex[key] = headerRow.index(key)

		#Loop over each row of the data
		for row in dataReader:

			#Create our message object
			message = Message()
	
			#Set the source of the message -- will be the same for every interface
			message.source = mappingObject["name"]

			#Loop over each mapping attribute, getting both the key and value
			for mapping in mappingObject["mapping"]:
				for key, value in mapping.iteritems():

					if hasHeader:
						#Set the appropriate field on the message object to our normalized value from the csv row
						setattr(message, value, normalize(row[headerToIndex[key]], value))

					else:
						setattr(message, value, normalize(row[int(key)], value))

			#So now our message is complete so yield it as per a generator
			yield message
