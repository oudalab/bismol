'''
Local Usage: tsnetest.py test_data_file.tsv 
Remote Usage: tsnetest.py test_data_file.tsv -remote
Runs a tsne simulation on given .tsv file
'''

import sys
from sklearn.manifold import TSNE
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.decomposition import TruncatedSVD
import numpy as np
import matplotlib
if(len(sys.argv) > 2 and sys.argv[2] == "-remote"):
	matplotlib.use('GTK')
import matplotlib.pyplot as plt
import csv

#accept file arg
filename = sys.argv[1]
data = []
#read through .tsv file, saving the text into data array
with open(filename) as tsv:
	for line in csv.reader(tsv, delimiter='\t'):
                data.append(line[1])

#fit and transform the data into vector form using TF-IDF
vectors = TfidfVectorizer().fit_transform(data)

print repr(vectors)

#reduce dimensionality to 50 before running tsne
X_reduced = TruncatedSVD(n_components=50, random_state=0).fit_transform(vectors)
#run tsne, convert to two dimensions
X_embedded = TSNE(n_components=2, perplexity=40, verbose=2).fit_transform(X_reduced)

#plot the data
fig = plt.figure(figsize=(10, 10))
ax = plt.axes(frameon=False)
plt.setp(ax, xticks=(), yticks=())
plt.subplots_adjust(left=0.0, bottom=0.0, right=1.0, top=0.9,
                wspace=0.0, hspace=0.0)
plt.scatter(X_embedded[:, 0], X_embedded[:, 1], marker="x")

plt.show()