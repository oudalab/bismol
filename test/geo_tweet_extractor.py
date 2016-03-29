# goal is to extract tweets with geocode field not null from file 'TT_tweets.csv'
import csv

geo_lines = []

with open('TT_tweets.csv','rb') as csvfile:
    r = csv.reader(csvfile, delimiter='`')
    for line in r:
        # format of line is: [tweet.id, tweet.source_url, tweet.text.encode('utf-8'), tweet.coordinates, tweet.created_at, key]
        # check the coordinates field
        if line[3] != '':
            geo_lines.append(line)

with open('TT_geo_tweets.csv', 'wb') as csvfile:
    w = csv.writer(csvfile, delimiter='`')
    for line in geo_lines:
        w.writerow(line)
