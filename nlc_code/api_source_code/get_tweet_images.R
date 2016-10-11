# ================================================================================================
#
# This R function downloads photos embedded within tweets
# It only captures photos uploaded by the user, or associated with a news article 
# 
# ================================================================================================

# Last updated: 07.16.14 by Emma Spiro

get_tweet_images <- function(user_ids, dbcon, datadir=""){
  
  cat("FINDING AND STORING TWEET IMAGES...\n")
  
  # pull current time and determine which db table to load things from
  tableDate<-format(Sys.time(), "%Y_%m")
  
  tweetsLoc <- dbGetQuery(dbcon, paste("select id_str, user_id, media from userTweets_", tableDate, 
                                       " where media_photo_collected=0", sep=""))
  tweetsLocUsers <- tweetsLoc[tweetsLoc$user_id%in%user_ids,]
  tweetsLocUse <- tweetsLocUsers[grep("photo", tweetsLocUsers$media),]
  tweetsLocUse$media <- gsub("photo\\|", "", tweetsLocUse$media)
  tweetsLocUse$media<- substring(tweetsLocUse$media, 2)
  for(i in 1:nrow(tweetsLocUse)){
    
    cat("  Working on image ", i, " out of ", nrow(tweetsLocUse),"...")
    # get time of capture and user id to store image
    captureTime <- format(Sys.time(), "%Y-%m-%d_%H-%M-%S")
    userid <- tweetsLocUse$user_id[i]
    
    # get the URL within the tweet
    urlloc <- tweetsLocUse$media[i]
    image_type <- unlist(lapply(strsplit(urlloc,"\\."), function(x) x[length(x)]))
    
    
    ## need to figure out how to capture the data type without having to pull the data...
    
    # retrieve and save image file
    system(paste("wget ", urlloc, " -O ", dataDir, "tweetmedia/", userid, "_", 
                 captureTime,".", image_type,sep=""))
    cat("done...")
    
    dbSendQuery(dbcon, paste("update userTweets_", tableDate, " set media_photo_collected=1 where id_str='", 
                             tweetsLocUse$id_str[i],"'", sep=""))
    cat("updating database, done. \n")
    }
  cat("DONE WITH ALL IMAGES.")
}

