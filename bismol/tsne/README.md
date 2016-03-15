Running t-SNE
=============

To run and visualize t-SNE with our data, follow these steps:

1. You will need to have rethinkdb, node, and python installed on your machine in order to follow these instructions.

2. In a terminal window, run the command "rethinkdb" (note, you may have to run "npm install" first to ensure you have all the necessary packages installed on your machine). The database is now up and running.

3. If you're running the database locally, run the script "python dbscript.py". This will create the database and the message tables needed to communicate t-SNE's updates to the client.

4. In a new terminal window, run the command "DEBUG=myapp:* npm start" to start the node server. The server is now ready to respond to changes in the database.

5. Open up your web browser and visit "http://localhost:8099". This is the port that node is monitoring.

6. In a new terminal window, type "python tsnetest.py ~/path/to/inputfile" (e.g. "python tsnetest.py ~/Documents/Programming/NEEL2016-training.tsv"). This will start the t-SNE algorithm and trigger the database updates that will then be rendered in your browser.  

Every 25 iterations through tsne's gradient descent, mytsne.py will update the message data it is operating on in the database, using the current x and y coordinates it has calculated. The node server is listening to changes to the database, and on such a change, it will emit a notification via socket.io to the client. The client will then re-draw itself whenever a complete batch of change notifications has been registered (e.g. if a given dataset contains 5000 messages, it will re-draw once it has received all 5000 row updates).

Alternatively, at step 6 you can run "python 20newsgroups.py". This will run t-SNE on the 20 Newsgroups training dataset from sklearn (11,314 elements, roughly equally distributed among the different categories). The colors have been chosen in order to provide optimal contrast (Kelly's 22 Colors of Maximum Contrast: http://www.iscc.org/pdf/PC54_1724_001.pdf).