from flask import Flask, render_template
from flask_socketio import SocketIO, send, emit
from time import sleep

app = Flask(__name__)
app.config['SECRET_KEY'] = 'secret!'
socketio = SocketIO(app)

@app.route("/")
def hello1():
	return render_template('home.html')

@socketio.on('message')
def handle_message(message):
	print('received message: ' + message)

@socketio.on('connect')
def test_connect():
	print('my response', {'data': 'Connected', 'count': 0})

@socketio.on('my event')
def sendmessages(data):
	events = [
		{'lat': 33.397, 'long': -100.644, 'title': 'Test status 1', 'dateTime': 'Today'},
		{'lat': 34.397, 'long': -100.644, 'title': 'Test status 2', 'dateTime': 'Today'},
		{'lat': 35.397, 'long': -100.644, 'title': 'Test status 3', 'dateTime': 'Today'},
		{'lat': 36.397, 'long': -100.644, 'title': 'Test status 4', 'dateTime': 'Today'},
		{'lat': 37.397, 'long': -100.644, 'title': 'Test status 5', 'dateTime': 'Today'},
		{'lat': 38.397, 'long': -100.644, 'title': 'Test status 6', 'dateTime': 'Today'},
		{'lat': 39.397, 'long': -100.644, 'title': 'Test status 7', 'dateTime': 'Today'},
		{'lat': 40.397, 'long': -100.644, 'title': 'Test status 8', 'dateTime': 'Today'},
		{'lat': 41.397, 'long': -100.644, 'title': 'Test status 9', 'dateTime': 'Today'},
		{'lat': 42.397, 'long': -100.644, 'title': 'Test status 10', 'dateTime': 'Today'},
		{'lat': 43.397, 'long': -100.644, 'title': 'Test status 11', 'dateTime': 'Today'},
		{'lat': 44.397, 'long': -100.644, 'title': 'Test status 12', 'dateTime': 'Today'},
		{'lat': 45.397, 'long': -100.644, 'title': 'Test status 13', 'dateTime': 'Today'},
		{'lat': 46.397, 'long': -100.644, 'title': 'Test status 14', 'dateTime': 'Today'}]
	
	for i in range(len(events)):
		sleep(5)
		print("Sending")
		emit('new message', events[i])
		#send(events[i])

socketio.run(app)
