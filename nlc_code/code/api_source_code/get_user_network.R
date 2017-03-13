# ================================================================================================
#
# This R function collects social network information from the Twitter REST API based on a set of user IDs
# 
# ================================================================================================

# Last updated: 07.08.14 by Emma Spiro

get_user_network <- function(user_ids, credential=NULL,out_only=TRUE){
  cat("WORKING TO GET USER SOCIAL TIES...")

  # Note roauth credential
  cred <- credential
  
  uNetworks <- vector("list", length(user_ids)) # to store data
  for (r in 1:length(user_ids)){
    cat("\n Working on user ", r, " out of ", length(user_ids),sep="")
    uNetworks[[r]] <- getUserEgonet(user_ids[r], is.ID=TRUE, 
                                    credential=cred,out.only=out_only)
    cat("\n Done with user", r, ". \n")
  }
  return(uNetworks)
}