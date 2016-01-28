class Message():
	'Encapsulates the message data used in the program internally'
	def __init__(self, url, source, text, geocode, timestamp):
		this.url = url
		this.source = source
		this.text = text
		this.geocode = geocode
		this.timestamp = timestamp

	def display():
		print 'From ', this.url, ' (', this.source, ') at ', this.timestamp, '.', 'Location: ', this.geocode
		print 'Message Body: ', this.text