# ================================================================================================
#
# This R script wraps user-based data collection from the Twitter REST API
# 
# ================================================================================================


## FUNCTION ARGUMENTS ##

# user_ids: list of Twitter user_ids
# cred: oauth signature credential
# dbCon: mysql database connection
# dataDir: Location to store data
#   - must contain /userdata/
#   - must contain /usertweets/
#   - must contain /profileimages/
# rawData: T/F to store raw data files in dataDir
# userINFO: T/F to collect user information
# userTimelines: T/F to collect user timelines (tweets)
# userNetworks: T/F to collect user social ties
# collectFollowers: should incoming relationships also be collected
# profilePhotos: T/F to collect profile photos
# tweetPhotos: T/F to collect tweet photos

collect_user_data <- function(user_ids, cred, dbCon,
                              dataDir, rawData=FALSE,
                              userInfo=TRUE,
                              userTimelines=FALSE,
                              userNetworks=FALSE, out.only=FALSE,
                              profilePhotos=FALSE,
                              tweetPhotos=FALSE){

  
  
  if(userInfo){
    
    # Pull data
    uInfo <- get_user_info(user_ids, credential=cred, rawdata=rawData, datadir=dataDir)
    uInfo <- do.call(rbind, uInfo) # Transform to data.frame
    uInfo$collected_datetime <- format(Sys.time(), tz="UTC")
    
    # pull current time and determine which db table to load things from and into
    tableDate<-format(Sys.time(), "%Y_%m")
    dbWriteTable(dbCon, paste("userInfo_", tableDate, sep=""), uInfo, 
                 row.names=FALSE, append=TRUE)
    
  }
  
  if(userTimelines){
    
    user_ids_notprotected<-uInfo$id_str[uInfo$protected==FALSE]  # only pull timelines for non-protected users
    
    # Pull data
    uTimelines <- get_user_timeline(user_ids_notprotected, credential=cred, 
                                    rawdata=rawData, datadir=dataDir, dbcon=dbCon)
    if (!is.null(unlist(lapply(uTimelines, dim)))) { #if there is any new data to load 

     uTimelines <- do.call(rbind, uTimelines) # Transform to data.frame
     rownames(uTimelines) <- NULL

    # pull current time and determine which db table to load things from and into
      tableDate<-format(Sys.time(), "%Y_%m")
      dbWriteTable(dbCon, paste("userTweets_", tableDate, sep=""), uTimelines, 
                   row.names=FALSE, append=TRUE)
   }
    
  }
  
  if(userNetworks){
    

    # Pull data
    uNetworks <- get_user_network(user_ids, credential=cred, out_only=out.only)
    uNetworks <- data.frame(do.call(rbind, uNetworks)) # Transform to data.frame
    
    # pull current time and determine which db table to load things from and into
    tableDate<-format(Sys.time(), "%Y_%m")
    dbWriteTable(dbCon, paste("socialTies_", tableDate, sep=""), uNetworks, row.names=FALSE, append=TRUE)
    
  }
  
  if(profilePhotos){
    # Pull data
    get_profile_images(user_ids, dbcon=dbCon, datadir=dataDir)
    
  }
  
  if(tweetPhotos){
    get_tweet_images(user_ids, dbcon=dbCon, datadir=dataDir)
  }
  
}