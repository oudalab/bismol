'''
Usage: python tsnetest.py file_type data_file.tsv
Example Usage: python tsnetest.py neel NEEL2016-training.tsv
Runs a tsne simulation on given .tsv file
'''

import sys
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.decomposition import TruncatedSVD
import numpy as np
import csv
sys.path.append("..")
import streaminterface
from streaminterface import streammanager
from streaminterface.streammanager import streammanager
import tsne
from tsne import mytsne
from tsne.mytsne import trustworthiness

#accept file arg
try: 
	filetype = sys.argv[1]
	filename = sys.argv[2]
except:
	print "Script run with invalid arguments"
	print "Usage: python tsnetest.py file_type data_file.tsv"
	print "Example Usage: python tsnetest.py neel NEEL2016-training.tsv"
	sys.exit(2)

text = []
urls = []

#read through message objects, saving text in text array
for message in streammanager(filetype, filename):
	text.append(message.text)
	urls.append(message.url)

#fit and transform the text into vector form using TF-IDF
vectors = TfidfVectorizer().fit_transform(text)

print repr(vectors)

#reduce dimensionality to 50 before running tsne
X_reduced = TruncatedSVD(n_components=50, random_state=0).fit_transform(vectors)
#run tsne, convert to two dimensions
X_embedded = mytsne.TSNE(n_components=2, perplexity=40, verbose=2, urls=urls, text=text).fit_transform(X_reduced)

trust = mytsne.trustworthiness(vectors, X_embedded)
print "Trustworthiness: {}".format(trust)