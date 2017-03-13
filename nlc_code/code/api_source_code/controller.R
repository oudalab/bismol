# ================================================================================================
#
# This R script controls user-based data collection from the Twitter REST API
# 
# ================================================================================================

## ADJUST WORKING DIR FOR PROJECT SPECIFIC DATA COLLECTION
workingDir <- "~/dc-user-centered-twitter/"
projectDir <- "~/dc-user-centered-twitter/"
dataDir <- "~/dc-user-centered-twitter/data/"

# Preliminary stuff
#load library
library(RMySQL)
library(httr)
library(RCurl)
library(rjson)
library(lubridate)
library(gdata)

## load API credentials - ADJUST
load(paste(projectDir,"data/user_sig_roauth.rdata",sep=""))

# Source helper functions
source(paste(workingDir,"code/collect_user_data.R",sep=""))
source(paste(workingDir,"code/parsing_functions.R",sep=""))
source(paste(workingDir,"code/get_user_info.R",sep=""))
source(paste(workingDir,"code/get_user_timeline.R",sep=""))
source(paste(workingDir,"code/get_user_network.R",sep=""))
source(paste(workingDir,"code/get_profile_images.R",sep=""))

## ADJUST TO SPECIFY DATABASE LOCATION FOR PROJECT
db_name <- 'twitter_dc_test'
db_user <- 'dc_test'
db_pwd <- 'tw1tt3r'
db_host <- 'techne.ischool.uw.edu'

cat("ESTABLISHING DATABASE CONNECTION....\n\n")

# Establish connection to database
mgr <- dbDriver("MySQL")
mycon <- dbConnect(mgr, user=db_user, host=db_host, 
                   dbname=db_name, password=db_pwd)

cat("READING IN LIST OF USER IDS....\n\n")

# Read in list of user IDs and shuffle
user_ids <- read.table(paste(projectDir,"data/user_ids.txt",sep=""))
user_ids <- as.character(user_ids[,1])
user_ids <- sample(user_ids)

if (any(is.na(user_ids)))
  user_ids <- user_ids[-which(is.na(user_ids))]

## ADJUST FUNCTION ARGUMENTS AS NECESSARY
## ADD RAW DATA DIRECTORY TO STORE RAW DATA
collect_user_data(user_ids, cred=user.signature, dbCon=mycon,
                  dataDir="", rawData=FALSE,
                  userInfo=TRUE,
                  userTimelines=TRUE,
                  userNetworks=FALSE, out.only=FALSE,
                  profilePhotos=FALSE,
                  tweetPhotos=FALSE)


dbDisconnect(mycon)



