
##read json file

import os
import sys
import json
import simplejson
import difflib
import csv
import pandas
from unidecode import unidecode


os.chdir('/data/rwjf-tweets') 
##reads each element of the file as a list

#filename = 'tweets.json'
filename = 'tweets_RUN_1.json'
#filename = 'tweets_RUN_2.json'

text_id=[]  #this is new
tweets_text = [] 
tweets_location = [] 
tweets_timezone = []
tweets_pic=[]
user_id=[]
user_name=[]
user_handle=[]
time=[]

# Loop over all lines
f = file(filename, "r")
lines = f.readlines()
for line in lines:
  try:
  tweet=simplejson.loads(line)
text=tweet['text'].lower()
text_id.append(tweet['id_str'])     
tweets_text.append(text)
time.append(tweet['created_at'])
tweets_location.append(tweet['user']['location'])
tweets_timezone.append(tweet['user']['time_zone'])
tweets_pic.append(tweet['user']['profile_image_url'])
user_id.append(tweet['user']['id_str'])
user_name.append(tweet['user']['name'])
user_handle.append(tweet['user']['screen_name'])

except ValueError:
  pass


##make empty dictionary to store this in 
keys = ['case_id','text','time', 'location', 'timezone', 'pic_url', 'user_id','user_name', 'user_handle' ]

#dictlist = [{key:'' for key in keys} for i in range(0, 545223)] 
dictlist = [{key:'' for key in keys} for i in range(0, 239249)] 
#dictlist = [{key:'' for key in keys} for i in range(0, 545223)] 



#fill dictionary
#for i in range(0,545223):
for i in range(0,239249):
  #for i in range(0,545223):
  dictlist[i]['case_id']=str(i)
dictlist[i]['text']=tweets_text[i]
dictlist[i]['time']=time[i]
dictlist[i]['location']=tweets_location[i]
dictlist[i]['timezone']=tweets_timezone[i]
dictlist[i]['pic_url']=tweets_pic[i]
dictlist[i]['user_id']=user_id[i]
dictlist[i]['user_name']=user_name[i]
dictlist[i]['user_handle']=user_handle[i]


tweetsDF=pandas.DataFrame.from_dict(dictlist)
tweetsDF.columns
tweetsDF.text
#tweetsDF.to_csv("gnip_tweets_data_04-18-2015_07-26-2015_addedFields_temp.csv", sep=",", encoding="utf-8",quoting=csv.QUOTE_NONNUMERIC)



## how many followers of foodsafetynews also appear in the data?
## is there a community of people interested in food safety?
## categorizing folks who talk about food safety: new sources, food lovers, those with an eating disorder
## Selection effect of those interested in food and food safety?
## Understanding selection effect can help understand any skew in results?
## Are young people more open to tweeting about food poisioing? More comfortable sharing this information on the platform
## understanding whether people view this as a news site or a social networking site might be helpful



for line in range(0,239248):
  sample_line=tweetsDF.text[line]
if "food poisioning" in sample_line:
  print line