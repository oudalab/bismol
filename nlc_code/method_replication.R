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


############### Helpful source code for gathering user information ###############
########### Provides more metadata than prepackaged TwitteR functions ############

source("C:/Users/ninac2/Documents/bismol/nlc_code/api_source_code/parsing_functions.R")
source("C:/Users/ninac2/Documents/bismol/nlc_code/api_source_code/get_user_info.R")
source("C:/Users/ninac2/Documents/bismol/nlc_code/api_source_code/get_user_timeline.R")
source("C:/Users/ninac2/Documents/bismol/nlc_code/api_source_code/get_user_network.R")
source("C:/Users/ninac2/Documents/bismol/nlc_code/api_source_code/collect_user_data.R")



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

## based on preliminary analyses, I don't think it's possible to gather ground truth data through blogs



############# Testing methods: Linking s ####################



############# Testing methods: Linking census/surname to users ####################

