Stream Manager
========================

This is the stream manager for Bismol. It will take in data from CSVs (as it is now) and will output Messages to be consumed by other aspects of the program.

'''
streammanager(mapping, data)
'''

The manager takes two arguments
- mapping -- A JSON file in the style of the examples (with more documentation to come) that maps the data file to the message object. Give this argument without the .json extension
- data -- A CSV or TSV file that may or may not contain a header. Specify the file extension in the argument

##Usage

The stream manager is meant to be called as a generator.

```
from streammanager import streammanager
for message in streammanager("reddit", "reddit.csv"):
	#manipulate the message here

```
