######################### Method Explore ###########################
##                                                                ##
### Code to explore Twitter data structure/replicate methods  ######
########## of estimating age/race/gender from profiles #############
##                                                                ## 
################## Author: N. Cesare 10/11/16 ######################


## Connect to the Twitter API to make sure we have the most up-to-date user information

rm(list=ls())
setwd("C:/Users/ninac2/Documents/bismol/nlc_code")

library(streamR)
library(twitteR)
library(RMySQL)
library(httr)
library(RCurl)
library(rjson)
library(lubridate)
library(gdata)
library(utils)

######## Authenticate API connection ##########
###### Using cred from Miscarriage Project ### 
## Twitter credentials for streamR and twitteR authentication
consumer_key <- "K9hdoAOqZLTRvgkVLJz9IhMiX"
consumer_secret<- "EJgiCTeV7MWzsLquNk9vQMk6cLEu0Fslz7yKdiQHq1hofB4hFr"
access_token<- "419220939-acWVGs8QC6GEgZXbZzvvKzV4QqohduFTmdh9jVHm"
access_token_secret<- "2kyY6AYVZSJhmoAE2NDegPVGS52LVi3UsFBjjWjFgVM4U"

## Parameters and URLs for streamR authentication
reqURL <- "https://api.twitter.com/oauth/request_token"
accessURL<- "https://api.twitter.com/oauth/access_token"
authURL<- "https://api.twitter.com/oauth/authorize"

## Windows users need to download cert file (cacert.pem). Macs do not.
download.file(url="http://curl.haxx.se/ca/cacert.pem", destfile="cacert.pem")

## create an object "cred" that will save the authenticated object for later sessions
twitCred<- OAuthFactory$new(consumerKey=consumer_key,consumerSecret=consumer_secret,
                            requestURL=reqURL,accessURL=accessURL,authURL=authURL)

## Will be shown pop-up window and asked to enter code at this step 
## Do NOT highlight beyond text when running this line or else code entry will auto-fail
twitCred$handshake(cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl"))

save(twitCred, file = "twitCred.RData")
#load("twitCred.RData")  # For later sessions 

setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_token_secret)  #Press "1" at the prompt


## Upload 'ground truth' data 

epic<-read.csv("C:/Users/ninac2/Documents/ground_truth_data/EPIC_groundTruth_data.csv", stringsAsFactors=FALSE)  #self-report survey (for gender, race/ethnicity)
mturk<-read.csv("C:/Users/ninac2/Documents/ground_truth_data/MTurk_groundTruth_data.csv", stringsAsFactors=FALSE) #Mechanical turk survey 

## Pull IDs from a random ID sample (available from previous project)
ids<-read.table("userIDSample_2014_08.txt")
ids<-as.character(ids[,1])

set.seed(234)
ids_samp<-sample(ids, 10000,replace=FALSE)

random_users<-lookupUsers(as.character(ids_samp), includeNA = FALSE)
random_users<-twListToDF(random_users)



################# Testing methods: gathering ground truth data ##################

## Can we gather ground truth data from users' URLs? (see Burger et al. 2011)
### something's going wrong with RCurl, so we'll just use TwitteR to get metdata for now

turk_users<-lookupUsers(as.character(mturk$id), includeNA=FALSE)
turk_users<-twListToDF(turk_users)

length(which(turk_users$description=="")) #only 249
url_index<-grep("http", turk_users$description, ignore.case=TRUE)

turk_users_description<-turk_users[grep("http", turk_users$description, ignore.case=TRUE),]

urls<-NULL
for(i in 1:dim(turk_users_description)[1]){
  url<-unlist(strsplit(turk_users_description$description[i], " "))[grep("http", unlist(strsplit(turk_users_description$description[i], " ")))]
  url<-gsub(",", "", url)
  url<-gsub(")", "", url)
  url<-gsub("!", "", url)
  url<-gsub(" ", "", url)
  url<-gsub(";", "", url)
  url<-gsub("➡️", "", url)
  urls<-c(urls, url)
}

urls<-gsub(urls, ",", "")
  
browseURL(urls[3], browser=getOption("Chrome"))

## based on preliminary analyses, I don't think it's possible to gather ground truth data through blogs...
## Seems to be quite a few soundcloud accounts linked to users, however



############# Testing methods: Tracking users' location ####################

## How many users actually have listed locations?
## How many of these locations are usable?
## Use new random users for this segment 

## Keep users who have a listed location and whose chosen language is english 
random_users_part<-random_users[which(random_users$location!="" & random_users$lang=="en"),]

## subsample further to check results by hand?
random_users_part<-random_users_part[sample(1:dim(random_users_part)[1], 100),]

random_users_part$location<-sub(",", "", random_users_part$location)
random_users_part$location<-sub("-", " ", random_users_part$location)
random_users_part$location<-sub("+", " ", random_users_part$location)
random_users_part$location<-sub("|", " ", random_users_part$location)
random_users_part$location<-sub("/", " ", random_users_part$location)
random_users_part$location<-trimws(random_users_part$location)


random_users_part$location_new<-NA

for(i in 1:dim(random_users_part)[1]){
  location<-unlist(strsplit(random_users_part$location[i], " "))
  if(length(location)>1){
    random_users_part$location_new[i]<- as.character(paste(location[c(1,2)], sep=" ", collapse = " "))
  }
  else{
    random_users_part$location_new[i]<-location
  }
}


random_users_part$location_new<-gsub(" ", "+", random_users_part$location_new)


## Help using the Google Maps API here: https://developers.google.com/maps/documentation/geocoding/start?csw=1#Geocoding
## limit: 2.5K requests per day

gm_api_key<-"AIzaSyDTWoQcb0a276MISAV0frT-iZGLO5ZHbTM"

geo_details<- function(location){
  url_for_request<- paste("https://maps.googleapis.com/maps/api/geocode/json?address=", location, "&key=", gm_api_key, sep="")

  return(fromJSON(getURL(url_for_request)))
}


result <- vector("list", length(random_users_part$location_new)) 

for(i in 1:length(random_users_part$location_new)){
  result[[i]]<-geo_details(random_users_part$location_new[[i]])
}

formatted_address<-NULL
for(i in 1:length(result)){
  if(length(result[[i]]$results)<1){
    address<-"NA"
  }
  else{
    address<-result[[i]]$results[[1]]$formatted_address
  }
  formatted_address<-c(formatted_address, address)
}



test<-as.data.frame(cbind(random_users_part$location_new, formatted_address))
sum(1,1,1,1,1,1,1,1,1,1,1,1,1)+length(which(test[,2]=="NA"))

### Prop of users with listed location (and lang. is EN): 0.579
### Estimated prop of users with accurate location in that subsample: 0.83
### Overall, we might hope to catch 48.1% of all users sampled with this method

## note: not all of these are areas smaller than a locality (although they include geocoordinate bounding boxes), and the system I'm using to parse the fields is pretty crude


############# Testing methods: Linking census/surname to users ####################


## R package gender allows you to match gender & name, specifying DOB range and historical dataset/method (ssa, ipums, more...)
## Again, I'll use the totally random sample

random_users_name<-random_users[which(random_users$lang=="en"),]


random_users_name$new_name<-NA
for(i in 1:dim(random_users_name)[1]){
  random_users_name$new_name[i]<-unlist(strsplit(random_users_name$name[i], " "))[1]
}

random_users_name$new_name<-tolower(random_users_name$new_name)
random_users_name<-random_users_name[,c(7,18)]
random_users_name$new_name<-tolower(random_users_name$new_name)

## The vast majority of twitters are between 18 and 65 years old (see Pew Demographics of social media users 2015)
## All but 6% were born after 1950.  We'll set the minimum search record year to 1940


random_users_name$gender<-NA
for(i in 1:dim(random_users_name)[1]){
    gender_new<-gender(unique(as.character(random_users_name$new_name[i])), years = c(1940, 2012), method = c("ssa", "ipums", "napp","kantrowitz", "genderize", "demo"), countries = c("United States", "Canada","United Kingdom"))
    if(dim(gender_new)[1]==1){
      random_users_name$gender[i]<-gender_new$gender
    }
    else{
      random_users_name$gender[i]<-NA
    }
}
gender_test<-gender(unique(as.character(random_users_name$new_name)), years = c(1940, 2012), method = c("ssa", "ipums", "napp",
                                                "kantrowitz", "genderize", "demo"), countries = c("United States", "Canada",
                                                                                                  "United Kingdom"))


## Able to capture 36.4% of users with this method. Not sure if those names are accurate 




