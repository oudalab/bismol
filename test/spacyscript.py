# spacy script playground
# using stuff from here: https://spacy.io/docs#tutorials

# code to use the streammanager
import sys
sys.path.append('..')
import bismol
from bismol import streaminterface
from bismol.streaminterface import streammanager
from bismol.streaminterface.streammanager import streammanager
#import Message
#
#for message in streammanager("reddit", "reddit.csv"):
#	print message

import spacy
from spacy.en import English
from spacy.parts_of_speech import PROPN
from spacy.parts_of_speech import NOUN

print "setting up nlp..."
nlp = spacy.en.English()
print "done."

def get_docs():
	# for now, just return a four-array for testing
	# TODO return array of actual tweets from tsv
	# TODO return using message objects
	#return ['Erik Holbrook is a cool guy','President Obama is also a cool guy.',
	#	'Peyton Manning won the Super Bowl last night.', 'He likes ice cream cold.']
	docs = []
	for message in streammanager("neel","NEEL2016-training.tsv"):
		docs.append(message)
	return docs
	

docs = get_docs()
# goal is to just print out all the proper nouns
# but there are a few different ways to do that, so lets compare them.
for unparsed_doc in docs:
	# first, tag and entity the string
	doc = nlp(unparsed_doc.text, parse=False)
	for ent in doc.ents:
		print ent.string+',',
	print
	
	
