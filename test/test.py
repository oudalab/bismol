import sys

sys.path.append("..")

import bismol
from bismol import streaminterface
from bismol.streaminterface import streammanager
from bismol.streaminterface.streammanager import streammanager

for message in streammanager("tweets", "tweets.csv"):
	print message.source
	print message.url
	print message.text
