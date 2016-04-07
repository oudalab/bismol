'''
Usage: python3 20newsgroups.py number_of_newsgroups
Runs a tsne simulation on the 20newsgroups training set (11,314 elements total)
'''

import sys
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.decomposition import TruncatedSVD
import numpy as np
from sklearn.datasets import fetch_20newsgroups
sys.path.append("..")
import tsne
from tsne import mytsne
from tsne.mytsne import trustworthiness

#get 20 Newsgroups dataset
categories = ['alt.atheism',
 'comp.graphics',
 'comp.os.ms-windows.misc',
 'comp.sys.ibm.pc.hardware',
 'comp.sys.mac.hardware',
 'comp.windows.x',
 'misc.forsale',
 'rec.autos',
 'rec.motorcycles',
 'rec.sport.baseball',
 'rec.sport.hockey',
 'sci.crypt',
 'sci.electronics',
 'sci.med',
 'sci.space',
 'soc.religion.christian',
 'talk.politics.guns',
 'talk.politics.mideast',
 'talk.politics.misc',
 'talk.religion.misc']

#accept file arg
try: 
	num_categories = sys.argv[1]
except:
	print("Script run with invalid arguments")
	print("Usage: python3 20newsgroups.py number_of_newsgroups")
	print("Example Usage: python3 20newsgroups.py 4")
	sys.exit(2)

twenty_train = fetch_20newsgroups(subset='train', shuffle=True, random_state = 42, categories = categories[:int(num_categories)])

#fit and transform the text into vector form using TF-IDF
vectors = TfidfVectorizer().fit_transform(twenty_train.data)

urls = []
colors = []
text = []

for i in range(len(twenty_train.data)):
	urls.append(str(i))
	text.append("Category: " + twenty_train.target_names[twenty_train.target[i]].upper() + "\n\n" + twenty_train.data[i])

for i in range(len(twenty_train.target)):
	colors.append(str(twenty_train.target[i]))

print(repr(vectors))

#reduce dimensionality to 50 before running tsne
X_reduced = TruncatedSVD(n_components=50, random_state=0).fit_transform(vectors)
#run tsne, convert to two dimensions
X_embedded = mytsne.TSNE(n_components=2, perplexity=40, verbose=2, urls=urls, colors=colors, text=text).fit_transform(X_reduced)

trust = mytsne.trustworthiness(vectors, X_embedded)
print("Trustworthiness: {}".format(trust))