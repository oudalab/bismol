import datetime
import json

class Message():
    '''Encapsulates the message data used in the program internally'''
    
    def __init__(self, id = None, source = None, text = None, geocode = None, timestamp = datetime.datetime.now(), tags = None):
        '''Constructor'''
        self.id = id
        self.source = source
        self.text = text
        self.geocode = geocode
        self.timestamp = timestamp
        self.decision = None
        self.confidence = None
        self.tags = tags

    def __str__(self):
       '''Override str method'''
       seq = ('From ', self.id, ' (', self.source, ') at ', self.timestamp.strftime("%Y-%m-%d %H:%M:%S"), '.',
                ' Location: ', self.geocode, '.\n', 'Message Body: ', self.text)
       return ''.join(seq)

    def send(self):
      '''Fill in send method. Sends a message to queue (or whatever we are using)'''
    pass

    def tojson(self):
        d = {}
        d["id"] = self.id
        d["source"] = self.source
        d["text"] = self.text
        d["geocode"] = self.geocode
        d["timestamp"] = self.timestamp
        d["decision"] = self.decision
        d["confidence"] = self.confidence
        d["tags"] = self.tags
        return json.dumps(d)

