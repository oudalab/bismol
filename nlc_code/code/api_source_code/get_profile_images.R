# ================================================================================================
#
# This R function downloads profile imagesbased on a set of Twitter user IDs
# 
# ================================================================================================

# Last updated: 07.16.14 by Emma Spiro

get_profile_images <- function(user_ids, dbcon, datadir=""){
  
  cat("WORKING TO GET PROFILE IMAGES...\n")
  
  # pull current time and determine which db table to load things from
  tableDate<-format(Sys.time(), "%Y_%m")
  dir.create(paste(datadir, "profileimages/", tableDate, sep=""))
  
  imagesLoc <- dbGetQuery(dbcon, paste("select id_str, profile_image_url from userInfo_", tableDate, sep=""))
  imagesLocUse <- imagesLoc[imagesLoc$id_str%in%user_ids,]
  imagesLocUse <- unique(imagesLocUse)
  if (length(which(is.na(imagesLocUse$profile_image_url)))>0)
    imagesLocUse <- imagesLocUse[-which(is.na(imagesLocUse$profile_image_url)),]
  
  for (i in 1:nrow(imagesLoc)){
    cat("  Working on image ", i, " out of ", nrow(imagesLoc),"...")
    # get time of capture and user id to store image
    captureTime <- format(Sys.time(), "%Y-%m-%d_%H-%M-%S")
    userid <- imagesLoc$id_str[i]
    
    # get image location and remove thumbnail indicator
    urlloc <- imagesLoc$profile_image_url[i]
    urlloc <- gsub("_normal","", urlloc)
    
    # get image format
    image_type <- unlist(lapply(strsplit(urlloc,"\\."), function(x) x[length(x)]))
    
    # retrieve and save image file
    system(paste("wget ", urlloc, " -O ", datadir, "profileimages/", tableDate,"/",userid, "_", captureTime,".", image_type,sep=""))
    cat("done.\n")
  }
  cat("DONE WITH ALL IMAGES.")
}

