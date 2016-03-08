To run and visualize tsne, follow these steps:

1. In a terminal window, run the command "rethinkdb" (note, you may have to run "npm install" first to ensure you have all the necessary packages installed on your machine). The database is now up and running.

2. In a new terminal window, run the command "DEBUG=myapp:* npm start" to start the node server. The server is now ready to respond to changes in the database.

3. Open up your web browser and visit "http://localhost:8099". This is the port that node is monitoring.

4. In a new terminal window, type "python tsnetest.py ~/path/to/inputfile" (e.g. "python tsnetest.py ~/Documents/Programming/NEEL2016-training.tsv"). This will start the tsne algorithm and trigger the database updates that will then be rendered in your browser.  

Every 25 iterations through tsne's gradient descent, mytsne.py will update the message data it is operating on in the database, using the current x and y coordinates it has calculated. The node server is listening to changes to the database, and on such a change, it will emit a notification via socket.io to the client. The client will then re-draw itself whenever a complete batch of change notifications has been registered (e.g. if a given dataset contains 5000 messages, it will re-draw once it has received all 5000 row updates).