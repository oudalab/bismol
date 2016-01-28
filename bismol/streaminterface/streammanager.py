import csv

import csv

with open('../data/reddit.csv', 'rb') as csvfile:
	myReader = csv.reader(csvfile, delimiter=' ', quotechar='|')
	for row in myReader:
		print ", ".join(row)

for item in interfaces:
	#create a new object with that name
	#call object.run
