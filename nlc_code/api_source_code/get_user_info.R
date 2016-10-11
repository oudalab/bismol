# ================================================================================================
#
# This R function collects account information from the Twitter REST API based on a set of user IDs
# 
# ================================================================================================

# Last updated: 07.08.14 by Emma Spiro


#############  Information from individual accounts  ###############

get_user_info <- function(user_ids, credential=NULL, rawdata=FALSE, datadir=""){
  cat("WORKING TO GET USER DATA...")
  runs <- ceiling(length(user_ids)/100) # num of queries needed 
  start <- 1
  end <- 100
  
  # Note roauth credential
  cred <- credential
  # Note directory to store raw json
  rawData <- rawdata
  dataDir <- datadir

  
  if (runs==1)
    if(length(user_ids)<end)
      end <- length(user_ids)
  
  uInfo <- vector("list", runs) # to store data
  for (r in 1:runs){
    
    # Check to see how many queries remain
    queries_left <- checkRL("users", credential=user.signature)
    queries_left <- queries_left$resources$users$'/users/lookup'$remaining
    
    # Check to make sure we are not adding NAs at the end
    if (end > length(user_ids))
      end <- length(user_ids)
    
    if (queries_left>0){
      u <- paste(user_ids[start:end], collapse=",") # put usernames in correct format
      uInfo[[r]] <- getUserInfo(u, is.ID=TRUE, bulk=TRUE, credential=cred, rawdata=rawData, datadir=dataDir)
      
    }
    else {
      cat("...Rate limit exceeded - sleeping for 15 minutes... \n")
      Sys.sleep(900)
    }
    
    start <- end + 1  
    end <- start + 99

    cat(".")
  }
  cat("done.\n")
  return(uInfo)
}

