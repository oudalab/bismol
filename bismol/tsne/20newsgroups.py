'''
Usage: python 20newsgroups.py
Runs a tsne simulation on the 20newsgroups training set (11,314 elements)
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
twenty_train = fetch_20newsgroups(subset='train', shuffle=True, random_state = 42)

#fit and transform the text into vector form using TF-IDF
vectors = TfidfVectorizer().fit_transform(twenty_train.data)

urls = []

for i in range(len(twenty_train.data)):
	urls.append(str(i))

print repr(vectors)

#reduce dimensionality to 50 before running tsne
X_reduced = TruncatedSVD(n_components=50, random_state=0).fit_transform(vectors)
#run tsne, convert to two dimensions
X_embedded = mytsne.TSNE(n_components=2, perplexity=40, verbose=2, urls=urls, colors=twenty_train.target, text=twenty_train.data).fit_transform(X_reduced)

trust = mytsne.trustworthiness(vectors, X_embedded)
print "Trustworthiness: {}".format(trust)