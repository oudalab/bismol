import os, glob, sys, sqlite3

if sys.argv[1] == "--help":
	print("\t\tParameter: directory containing .csv to load with pre classification")
	sys.exit()

con = sqlite3.connect('pepto.db')

for file in glob.glob(sys.argv[1]+"*.csv"):
	print("Opening file "+file+"...")
	curr_file = open(file, "r")
	lines = curr_file.readlines()
	line_list = [x.strip() for x in lines]
	for line in line_list:
		split_str = line.split(',')
		preclass_val = -1
		if split_str[1] == "1":
			preclass_val = 1
		elif split_str[2] == "1":
			preclass_val = 2
		elif split_str[3] == "1":
			preclass_val = 3
		cur = con.cursor()
		print("Updating tweet "+split_str[0]+" with preclass "+str(preclass_val))
		cur.execute("UPDATE tweets SET preclass = ? WHERE tweetid = ?", (preclass_val, split_str[0]))
con.commit()
con.close()

