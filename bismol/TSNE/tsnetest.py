'''
Local Usage: tsnetest.py test_data_file.tsv 
Remote Usage: tsnetest.py test_data_file.tsv -remote
Runs a tsne simulation on given .tsv file
'''

import sys
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.decomposition import TruncatedSVD
import numpy as np
import matplotlib
if(len(sys.argv) > 2 and sys.argv[2] == "-remote"):
	matplotlib.use('GTK')
import matplotlib.pyplot as plt
import csv
import json
import io
sys.path.append("..")
import streaminterface
from streaminterface import streammanager
from streaminterface.streammanager import streammanager
import TSNE
from TSNE import mytsne
from TSNE.mytsne import trustworthiness

#accept file arg
filename = sys.argv[1]
text = []
urls = []
#read through message objects, saving text in text array
for message in streammanager("neel", filename):
	text.append(message.text)
	urls.append(message.url)

#fit and transform the text into vector form using TF-IDF
vectors = TfidfVectorizer().fit_transform(text)

print repr(vectors)

#reduce dimensionality to 50 before running tsne
X_reduced = TruncatedSVD(n_components=50, random_state=0).fit_transform(vectors)
#run tsne, convert to two dimensions
X_embedded = mytsne.TSNE(n_components=2, perplexity=40, verbose=2, urls=urls, text=text).fit_transform(X_reduced)
X_dict = dict(X_embedded)

'''with io.open("EmbeddedData.json", mode="w", encoding="utf-8") as f:
	json.dump(X_dict, f, ensure_ascii=False, encoding="utf-8")'''

trust = mytsne.trustworthiness(vectors, X_embedded)
print "Trustworthiness: {}".format(trust)

#plot the data
'''fig = plt.figure(figsize=(10, 10))
ax = plt.axes(frameon=False)
plt.setp(ax, xticks=(), yticks=())

points_with_annotation = []
for i in range(len(X_embedded)):
    point, = plt.plot(X_embedded[i][0], X_embedded[i][1], 'x', markersize=5)
    if(i % 2 == 0):
	    annotation = ax.annotate(text[i],
	        xy=(X_embedded[i][0], X_embedded[i][1]), xycoords='text',
	        xytext=(X_embedded[i][0] - 1, X_embedded[i][1] + 0.1), textcoords='text',
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

plt.show()'''