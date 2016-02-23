'''
Local Usage: tsnetest.py test_data_file.tsv 
Remote Usage: tsnetest.py test_data_file.tsv -remote
Runs a tsne simulation on given .tsv file
'''

import sys
from sklearn.manifold import TSNE
from sklearn.manifold.t_sne import trustworthiness
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.decomposition import TruncatedSVD
import numpy as np
import matplotlib
if(len(sys.argv) > 2 and sys.argv[2] == "-remote"):
	matplotlib.use('GTK')
import matplotlib.pyplot as plt
import csv
import json
from streammanager import streammanager

#accept file arg
filename = sys.argv[1]
data = []
#read through .tsv file, saving the text into data array
'''with open(filename) as tsv:
	for line in csv.reader(tsv, delimiter='\t'):
                data.append(line[1])'''
for message in streammanager("neel", filename):
	data.append(message.text)

#fit and transform the data into vector form using TF-IDF
vectors = TfidfVectorizer().fit_transform(data)

print repr(vectors)

#reduce dimensionality to 50 before running tsne
X_reduced = TruncatedSVD(n_components=50, random_state=0).fit_transform(vectors)
#run tsne, convert to two dimensions
X_embedded = TSNE(n_components=2, perplexity=40, verbose=2).fit_transform(X_reduced)
X_dict = dict(X_embedded)

'''with open("EmbeddedData.json", mode="w") as f:
	json.dump(X_dict, f)'''

trust = trustworthiness(vectors, X_embedded)
print "Trustworthiness: {}".format(trust)

#plot the data
fig = plt.figure(figsize=(10, 10))
ax = plt.axes(frameon=False)
plt.setp(ax, xticks=(), yticks=())

points_with_annotation = []
for i in range(len(X_embedded)):
    point, = plt.plot(X_embedded[i][0], X_embedded[i][1], 'x', markersize=5)
    if(i % 2 == 0):
	    annotation = ax.annotate(data[i],
	        xy=(X_embedded[i][0], X_embedded[i][1]), xycoords='data',
	        xytext=(X_embedded[i][0] - 1, X_embedded[i][1] + 0.1), textcoords='data',
	        horizontalalignment="left",
	        arrowprops=dict(arrowstyle="simple",
	                        connectionstyle="arc3,rad=-0.2"),
	        bbox=dict(boxstyle="round", facecolor="w", 
	                  edgecolor="0.5", alpha=0.9)
	        )
	    # by default, disable the annotation visibility
	    annotation.set_visible(False)

	    points_with_annotation.append([point, annotation])


def on_move(event):
    visibility_changed = False
    for point, annotation in points_with_annotation:
        should_be_visible = (point.contains(event)[0] == True)

        if should_be_visible != annotation.get_visible():
            visibility_changed = True
            annotation.set_visible(should_be_visible)

    if visibility_changed:        
        plt.draw()

on_move_id = fig.canvas.mpl_connect('motion_notify_event', on_move)

plt.show()