import matplotlib.pyplot as plt
import numpy as np

'''unmodified = []
modified = []
with open('times.txt', 'r') as f:
	for line in f:
		unmodified.append(float(line[:-1]))

with open('modified.txt', 'r') as f:
	for line in f:
		modified.append(float(line[:-1]))

# plot the data
num_xticks = [i + 1 for i in range(20)]
plt.figure(figsize=(12, 8), dpi=100)
plt.plot(num_xticks, modified, 'r--', label='Modified t-SNE, No Interaction', linewidth=2.5) 
plt.plot(num_xticks, unmodified, 'b', label='Unmodified t-SNE', linewidth=2.5)
plt.xlabel("Number of Newsgroup Categories", fontsize=18)
plt.ylabel("Time (s)", fontsize=18)
plt.legend(loc=2, fontsize=18)
plt.grid(True)
plt.tight_layout()
#plt.show()
plt.savefig('runtimes')'''

'''unmodified = []
modified = []
with open('orig_accuracies.txt', 'r') as f:
	for line in f:
		unmodified.append(float(line[:-1]))

with open('mod_accuracies.txt', 'r') as f:
	for line in f:
		modified.append(float(line[:-1]))

# plot the data
num_xticks = [i + 1 for i in range(20)]
plt.figure(figsize=(12, 8), dpi=100)
plt.plot(num_xticks, modified, 'r--', label='Modified t-SNE, No Interaction', linewidth=2.5) 
plt.plot(num_xticks, unmodified, 'b', label='Unmodified t-SNE', linewidth=2.5)
plt.xlabel("Number of Newsgroup Categories", fontsize=18)
plt.ylabel("Trustworthiness", fontsize=18)
plt.legend(loc=1, fontsize=18)
plt.grid(True)
plt.ylim(0, 1)
plt.tight_layout()
#plt.show()
plt.savefig('trustworthiness')'''


dblag = []
totallag = []
with open('dblag.txt', 'r') as f:
	for line in f:
		dblag.append(float(line[:-1]))

with open('totallag.txt', 'r') as f:
	for line in f:
		totallag.append(float(line[:-1]))

# get totallag without dblag included, to show on bar chart
totallag = [(y - x) for x, y in zip(dblag, totallag)]
print(totallag)

# plot the data
num_xticks = [i + 1 for i in range(20)]
index = np.arange(20)
#plt.figure(figsize=(12, 8), dpi=100)
rects1 = plt.bar(index, dblag, .4, color='b', label="Database Processing Time")
rects2 = plt.bar(index, totallag, .4, color='r', bottom=dblag, label="Event Processing Time")
#plt.plot(num_xticks, totallag, 'r--', label='End-to-End Lag Time', linewidth=2.5)
#plt.plot(num_xticks, dblag, 'b', label='Database Processing Time', linewidth=2.5) 
plt.xlabel("Number of Newsgroup Categories", fontsize=18)
plt.ylabel("Time (ms)", fontsize=18)
plt.xticks(index + .2, num_xticks)
plt.legend(loc=2, fontsize=18)
plt.grid(True)
plt.tight_layout()
plt.show()
#plt.savefig('lagtimes')