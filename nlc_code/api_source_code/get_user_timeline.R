# ================================================================================================
#
# This R function collects user timelines (i.e. tweets) from the Twitter REST API based on a set of user IDs
# 
# ================================================================================================

# Last updated: 07.08.14 by Emma Spiro

get_user_timeline <- function(user_ids, credential=NULL, rawdata=FALSE, datadir="", dbcon=NULL){
  
  # Note roauth credential
  cred <- credential
  # Note directory to store raw json
  dataDir <- datadir
  rawData <- rawdata
  
  # Prep data
  userTimeline <- vector("list", length(user_ids))
  names(userTimeline) <- user_ids
  
  cat("WORKING TO GET USER TWEETS...\n")
  
  ## Has built-in functions to check rate limiting 
  for (r in 1:length(user_ids)){
    cat("Working on user ",r, " out of ", length(user_ids), " ID: ", as.character(user_ids)[r], sep="")
    
    # First check to see if any data exists for this user
    if (!is.null(dbcon)){
      # pull current time and determine which db table to load things from and into
      currentTime<-Sys.time()
      currentDate<-unlist(lapply(strsplit(as.character(currentTime), " "), function(x) x[1]))
      currentDate<-unlist(lapply(strsplit(as.character(currentDate), "-"), function(x) x[1:2]))
      tableDate<-paste(currentDate[1], currentDate[2], sep="_") # current table
      
      mons<-c("01","02","03","04","05","06","07","08","09","10","11","12")
      ind<-match(currentDate[2], mons)
      if (ind==1)
        ind=13
      pastTabNam<-paste(currentDate[1], mons[ind-1], sep="_") # last table
      last.collected <- dbGetQuery(mycon, paste("select id_str from userTweets_",tableDate,
                                                " where user_id_str=",user_ids[r]," order by entry_id limit 1",sep=""))
      
      if (nrow(last.collected)==0)
        last.collected <- dbGetQuery(mycon, paste("select id_str from userTweets_",
                                                  pastTabNam," where user_id_str=",user_ids[r]," order by entry_id limit 1",sep=""))
      if (nrow(last.collected)==0){
        since.id <- ""
      } else {
        since.id=last.collected
      }
      
    } else { # If no database connection is provided we assume this is the first time and collect all tweets
      since.id=""
    }
    
    res <- getUserTimeline(user_ids[r],is.ID=TRUE, since.id=since.id, 
                                  credential=cred, rawdata=rawData, datadir=dataDir)
    res$text <- cleanText(res$text)
    res$user_description <- cleanText(res$user_description)
    res$user_location <- cleanText(res$user_location)
    res$user_name <- cleanText(res$user_name)
    res$user_location <- cleanText(res$user_location)
    
   
   userTimeline[[r]] <- res 
    cat("done. \n")
  }
  return(userTimeline)
  
}


