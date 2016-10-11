# ================================================================================================
#
# This Script contains a set of parsing function for JSON objects collected from the Twitter API
# 
# ================================================================================================

# This script is build from a prior vresion written by Emma S. Spiro and Sean Fitzhugh (UCI)
# Last Updated 11.07.14 by ESS



# PARSE USER JSON OBJECT
parseUserObj <- function(json_object, timeline=FALSE){
  dat <- json_object
  if (!is.null(dat$url)){
    url <- dat$url
  } else {
    url=""
  }
  if (!is.null(dat$entities$url)){
    url_expanded <- paste(unlist(lapply(dat$entities$url$urls, function(x) x$expanded_url)), collapse="|")
  } else {
    url_expanded=""
  }
  if (!is.null(dat$time_zone)){
    tz <- dat$time_zone
  } else {
    tz=""
  }
  if (!is.null(dat$utc_offset)){
    utc <- dat$utc_offset
  } else {
    utc=""
  }
  if (!is.null(dat$description)){
    des <- dat$description
  } else {
    des=""
  }
  if (!is.null(dat$location)){
    loc <- dat$location
  } else {
    loc=""
  }
  if (!is.null(dat$profile_banner_url)){  
    loc <- dat$profile_banner_url
  } else {
    profile_banner_url=""
  }
  if (!is.null(dat$profile_image_url)){
    profile_image <- dat$profile_image_url
  } else {
    profile_image=""
  }
  if (!is.null(dat$profile_banner_url)){
    profile_banner_url <- dat$profile_banner_url
  } else {
    profile_banner_url=""
  }
  if (!is.null(dat$profile_background_image_url)){
    background_image_url <- dat$profile_background_image_url
  } else {
    background_image_url =""
  }
  if (!is.na(match("status",names(dat)))){
    laststatus <- unique(parseTweetObj(dat$status, timeline=timeline))
    laststatus <- laststatus[,-c(18:52)]
    colnames(laststatus) <- paste("laststatus_", colnames(laststatus), sep="")
  } else {
    laststatus=matrix(NA, nr=1, nc=29)
    nams <- c("laststatus_created_at",             
              "laststatus_id",                       
              "laststatus_id_str",                  
              "laststatus_text",                     
              "laststatus_source",                   
              "laststatus_truncated",                
              "laststatus_in_reply_to_status_id_str",
              "laststatus_in_reply_to_user_id_str",  
              "laststatus_in_reply_to_screen_name",  
              "laststatus_geo",
              "laststatus_coordinates",  
              "laststatus_contributors",
              "laststatus_is_quote_status",
              "laststatus_retweet_count", 
              "laststatus_favorite_count",
              "laststatus_possibly_sensitive",       
              "laststatus_user_id",
              "laststatus_hashtags",                               
              "laststatus_urls",                     
              "laststatus_media",                    
              #"laststatus_lang",
              paste("laststatus_place_", c("attributes","bounding_box","country","country_code","full_name",   
                                           "id","name","type","url"), sep=""))
    colnames(laststatus) <- nams     
  }
  res <- data.frame(id=as.character(dat$id), 
                    id_str=dat$id_str, 
                    name=dat$name, #user specified name
                    screen_name=dat$screen_name, 
                    location=loc, #user defined location
                    description=des, #user specified description
                    url=url, # user specified url
                    url_expanded=url_expanded,
                    protected=dat$protected, #T/F
                    followers_count=dat$followers_count, # number of followers
                    friends_count=dat$friends_count, # number of friends
                    listed_count=dat$listed_count, # num of public lists that this user is a member of.
                    created_at=dat$created_at, # date created
                    favourites_count=dat$favourites_count, #posts favorited by user
                    utc_offset=utc, #offset from utc
                    time_zone=tz, # time zone of the user
                    geo_enabled=dat$geo_enabled, #T/F user has enabled the possibility of geotagging their Tweets.
                    verified=dat$verified, # T/F verified account 
                    statuses_count=dat$statuses_count, # number of tweets
                    lang=dat$lang, # user declared language
                    contributors_enabled=dat$contributors_enabled, #T/F "contributor mode" enabled
                    is_translator=dat$is_translator,
                    is_translation_enabled=dat$is_translation_enabled,
                    profile_background_color=dat$profile_background_color,                            
                    profile_background_image_url=background_image_url,                            
                    profile_background_tile=dat$profile_background_tile,                            
                    profile_image_url=profile_image,                           
                    profile_banner_url=profile_banner_url,                           
                    profile_link_color=dat$profile_link_color,                            
                    profile_sidebar_border_color=dat$profile_sidebar_border_color,                           
                    profile_sidebar_fill_color=dat$profile_sidebar_fill_color,                               
                    profile_text_color=dat$profile_text_color,                         
                    profile_use_background_image=dat$profile_use_background_image,                      
                    has_extended_profile=dat$has_extended_profile,                           
                    default_profile=dat$default_profile
  )
  res <- cbind(res, laststatus)
  rownames(res) <- NULL
  return(res)
}


# PARSE TWEET JSON OBJECT
parseTweetObj <- function(json_object, timeline=FALSE){
  dat <- json_object
  if (!is.null(dat$place)){
    place <- parsePlaceObj(dat$place)
  } else {
    place <- matrix(NA, nr=1, nc=9)
  }
  colnames(place) <- paste("place_", c("attributes","bounding_box","country","country_code","full_name",   
                                       "id","name","type","url"), sep="")
  entities <- entitiesTweetObj(dat$entities)
  if (!timeline){
    if (!is.na(match("user",names(dat)))){
      user <- parseUserObj(dat$user)
      colnames(user) <- paste("user_", colnames(user), sep="")
    } else {
      user <- matrix(NA, nr=1, nc=35)
      colnames(user) <- c("user_id","user_id_str",
                          "user_name",           
                          "user_screen_name",     
                          "user_location",        
                          "user_description",  
                          "user_url", 
                          "user_url_expanded",   
                          "user_protected",       
                          "user_followers_count",      
                          "user_friends_count",         
                          "user_listed_count",          
                          "user_created_at",        
                          "user_favourites_count",            
                          "user_utc_offset",      
                          "user_time_zone",      
                          "user_geo_enabled",     
                          "user_verified",        
                          "user_statuses_count",       
                          "user_lang",        
                          "user_contributors_enabled", 
                          "user_is_translator",  
                          "user_is_translation_enabled",
                          "user_profile_background_color"  , 
                          "user_profile_background_image_url",   
                          "user_profile_background_tile",  
                          "user_profile_image_url",      
                          "user_profile_banner_url",                    
                          "user_profile_link_color",      
                          "user_profile_sidebar_border_color",         
                          "user_profile_sidebar_fill_color",  
                          "profile_text_color", 
                          "user_profile_use_background_image",                            
                          "user_has_extended_profile",           
                          "user_default_profile")   
    }
  } else {	# if pasring timelines tweets we don't need to look at most recent status
    if (!is.na(match("user",names(dat)))){
      user <- parseUserObj(dat$user)[1:35]
      colnames(user) <- paste("user_", colnames(user),sep="")
    } else {
      user=rep(NA, 35)
      names(user) <- c("user_id","user_id_str",
                       "user_name",           
                       "user_screen_name",     
                       "user_location",        
                       "user_description",  
                       "user_url", 
                       "user_url_expanded",   
                       "user_protected",       
                       "user_followers_count",      
                       "user_friends_count",         
                       "user_listed_count",          
                       "user_created_at",        
                       "user_favourites_count",            
                       "user_utc_offset",      
                       "user_time_zone",      
                       "user_geo_enabled",     
                       "user_verified",        
                       "user_statuses_count",       
                       "user_lang",        
                       "user_contributors_enabled", 
                       "user_is_translator",  
                       "user_is_translation_enabled",
                       "user_profile_background_color"  , 
                       "user_profile_background_image_url",   
                       "user_profile_background_tile",  
                       "user_profile_image_url",      
                       "user_profile_banner_url",                    
                       "user_profile_link_color",      
                       "user_profile_sidebar_border_color",         
                       "user_profile_sidebar_fill_color",  
                       "user_profile_text_color", 
                       "user_profile_use_background_image",                            
                       "user_has_extended_profile",           
                       "user_default_profile")  
      user <- t(data.frame(user))
    }
  }
  if (length(grep("id_str",names(dat$contributors)))>0){ #bypasses bug where dat$contributors is not null, but contributors$id_str does not exist 
    if (!is.null(dat$contributors)){
      contrib <- dat$contributors$id_str
    } else {
      contrib <- ""
    }
  } else {
    contrib <- ""
  }
  if (!is.null(dat$in_reply_to_status_id_str)){
    irts <- dat$in_reply_to_status_id_str
  } else {
    irts <- ""
  }
  if (!is.null(dat$in_reply_to_user_id_str)){
    irtu <- dat$in_reply_to_user_id_str
  } else {
    irtu <- ""
  }
  if (!is.null(dat$in_reply_to_user_screen_name)){
    irtsn <- dat$in_reply_to_user_screen_name
  } else {
    irtsn <- ""
  }
  if (!is.null(dat$coordinates)){
    coord <- paste(dat$coordinates$coordinates,collapse=" ")
  } else {
    coord=""
  }
  if (!is.null(dat$geo)){
    geo <- paste(dat$coordinates$geo,collapse=" ")
  } else {
    geo=""
  }
  if (!is.null(dat$is_quote_status)){
    is_quote <- dat$is_quote_status
  } else {
    is_quote=""
  }
  if (!is.null(dat$possibly_sensitive)){
    ps <- dat$possibly_sensitive
  } else {
    ps=""
  }
  res <- data.frame(created_at=dat$created_at, 
                    id=dat$id,
                    id_str=dat$id_str, 
                    text=dat$text, 
                    source=dat$source, # Utility used to post the Tweet
                    truncated=dat$truncated,
                    in_reply_to_status_id_str=irts,
                    in_reply_to_user_id_str=irtu,
                    in_reply_to_screen_name=irtsn,
                    geo=geo,
                    coordinates=coord,
                    contributors=contrib,
                    is_quote_status=is_quote,
                    retweet_count=dat$retweet_count,
                    favorite_count=dat$favorite_count,
                    possibly_sensitive=ps # T/F indicator that the URL contained in the tweet may contain content or media identified as sensitive content.
  )
  res <- cbind(res, user, entities, place)
  rownames(res) <- NULL
  return(res)
}	

# PARSE RETWEET JSON OBJECT
parseRetweetObj <- function(json_object){
  dat <- json_object
  rt_status <- parseTweetObj(dat)
  rt_status <- rt_status[,-grep("laststatus", colnames(rt_status))]
  orig_status <- parseTweetObj(dat$retweeted_status)
  orig_status <- orig_status[,-grep("laststatus", colnames(orig_status))]
  colnames(orig_status) <- paste("retweeted_status_",colnames(orig_status), sep="")
  res <- cbind(rt_status, orig_status)
  res <- apply(res, 2, as.character)
  return(res)
}	

# PARSE PLACE OBJECT
parsePlaceObj <- function(json_object){
  # NEED TO FINISHED
  dat <- json_object
  attrib <- unlist(dat$attributes)
  if (is.null(attrib))
    attrib=""
  bb <- paste(dat$bounding_box$type, paste(dat$bounding_box$coordinates, sep=","), sep=": ", collapse="")
  if (is.null(bb))
    bb=""
  res <- data.frame(
    attributes=attrib,
    bounding_box=bb,
    country=dat$country,
    country_code=dat$country_code,
    full_name=dat$full_name,
    id=dat$id, #ID representing this plac
    name=dat$name,
    place_type=dat$place_type,
    url=dat$url
  )
  rownames(res) <- NULL
  return(res)		
}

# GET USER OBJECT ENTITIES
entitiesUserObj <- function(json_object){
  tmp <- json_object
  t <- tmp$entities$url
  t2 <- tmp$entities$description
  u <- paste(unlist(lapply(t$urls, function(x) unlist(x)[grep("expanded_url", names(x))])), collapse=" ")
  u2 <- paste(unlist(lapply(t2$urls, function(x) unlist(x)[grep("expanded_url", names(x))])), collapse=" ")
  res <- paste(u, u2, collapse=" ")
  names(res) <- c("user_url_expanded")
  return(res)
}

# GET TWEET OBJECT ENTITIES
entitiesTweetObj <- function(json_object){
  dat <- json_object
  mentions=hashtags=media=urls=""
  if (!is.na(match("user_mentions", names(dat))))
    user_mentions <- paste(unlist(lapply(dat$user_mentions, function(x) x$id_str)), collapse=" ")
  if (!is.na(match("hashtags", names(dat))))
    hashtags <- paste(unlist(lapply(dat$hashtags, function(x) x$text)), collapse=" ")
  if (!is.na(match("urls", names(dat))))
    urls <- paste(unlist(lapply(dat$urls, function(x) unlist(x)[grep("expanded_url", names(x))])), collapse=" ")
  if (!is.na(match("media", names(dat)))){
    media_type <- paste(unlist(lapply(dat$media, function(x) x$type)), collapse=" ")
    media_url <- paste(unlist(lapply(dat$media, function(x) x$media_url)), collapse=" ")
    media <- paste(media_type, media_url, sep="|",collapse=" ")
  }
  res <- cbind(user_mentions, hashtags, urls, media)
  return(res)
}

# CLEAN TEXT FOR CHARACTERS THAT MESS UP THE DATABASE
cleanText <- function(text_vector){
  text_vector<-sapply(text_vector, function(x) gsub("\'","\"",x))
  text_vector<-sapply(text_vector, function(x) gsub("[\b\t\n]"," ",x))
  return(text_vector)		
}

# CHECK THE RATE LIMIT _ NUMBER OF QUERIES LEFT
checkRL <- function(type,credential){
  base.url <- "https://api.twitter.com/1.1/application/rate_limit_status.json?resources="
  rl <- GET(url=paste(base.url, type, sep=""), config=credential)
  if (rl$status==429){
    print(cat("rate limited, sleeping for 15min\n"))
    Sys.sleep(60*15)
    rl <- GET(url = paste(base.url,type,sep=""), config=credential) # make first api call
  }
  rl <- content(rl, as="text") 
  rl <- fromJSON(rl)
  return(rl)
}

# FUNCTION TO GET USER COVARIATES
getUserInfo <- function(users, is.ID=FALSE, bulk=TRUE, credential=NULL, rawdata=FALSE, datadir=""){
  require(httr)
  if (bulk){
    ui.base.url <- "https://api.twitter.com/1.1/users/lookup.json?"
  } else {
    ui.base.url <- "https://api.twitter.com/1.1/users/show.json?"
  }
  
  if (is.ID){
    ui.base.url <- paste(ui.base.url, "user_id=", sep="")
  } else {
    ui.base.url <- paste(ui.base.url, "screen_name=", sep="")
  }
  # THIS DOES NOT MONITOR RATE LIMITES PLEASE DO THAT FROM BASH SCRIPT
  tmp <- GET(url = paste(ui.base.url,users,sep=""), config=user.signature)
  dat <- content(tmp, as ="text") 
  
  # save raw JSON
  if (rawdata){
    tim <- Sys.time()
    tim <- gsub(" ","_",tim)
    write(dat, file=paste(datadir,"/userdata/",tim,".JSON",sep=""))
  }

  # Parse json
  dat <- fromJSON(dat)
  
  if (bulk){
    if (tmp$status==200){ # everything ok
      res <- do.call(rbind, lapply(dat, parseUserObj, timeline=FALSE))
      note <- rep("", nrow(res))
      res <- cbind(res, note)
      u <- unlist(strsplit(users, ","))
      if (is.ID){
        u <- u[which(u%in%tolower(as.character(res$id_str))==FALSE)]
        m <- matrix(NA, nr=length(u), ncol=ncol(res))
        colnames(m) <- colnames(res)
        m[,"id_str"]=u
        m[,"note"] <- rep("user not found")
      } else {
        u <- u[which(u%in%tolower(as.character(res$screen_name))==FALSE)]
        m <- matrix(NA, nr=length(u), ncol=ncol(res))
        colnames(m) <- colnames(res)
        m[,"screen_name"]=u
        m[,"note"] <- rep("user not found")
      }
      res <- rbind(res, m)
    } else {
      res <- "Users not found."
    }
    # need to adjust for users that were not found
    
  } else {
    if (tmp$status==200){
      res <- parseUserObj(dat)
    } else {
      res <- "Users not found."
    }
  }
  # clean some of the text elements so as not to mess up the db
  res$description <- cleanText(res$description)
  res$laststatus_text <- cleanText(res$laststatus_text)
  rownames(res) <- NULL
  return(res)
}


# FUNCTION TO GET USER TWEETS
getUserTimeline <- function(user, is.ID=FALSE, since.id="", credential=NULL, rawdata=FALSE, datadir=""){
  require(httr)
  require(rjson)
  # note API call 
  base.url <- "https://api.twitter.com/1.1/statuses/user_timeline.json?"
  # updated base url for API call
  # check to see if we are making call from user id or screen name
  if (is.ID){
    base.url <- paste(base.url, "user_id=", sep="")
  } else {
    base.url <- paste(base.url, "screen_name=", sep="")
  } 
  
  # if no since.id is supplied we default to grabbing all possible data from the user timeline
  # this should be the call made for new users
  if (since.id==""){ # grab entire history
    tweets <- matrix(NA, nr=0, nc=64) # to store data in
    tmp <- GET(url = paste(base.url,user,"&count=200",sep=""), config=credential) # make first api call
    # check to make sure we were not rate limited, if sleep and rate limited check again 
    if (tmp$status==429){
      cat("Sleeping for 15 min...starting at ", as.character(Sys.time()), "\n", sep="")
      Sys.sleep(60*15)
      tmp <- GET(url = paste(base.url,user,sep=""), config=credential) # make first api call
    }
    
    if (tmp$status!=200){ # something went wrong: service unavail or bad authorization
      cat("bad results, trying again\n")
      Sys.sleep(15)
      tmp <- GET(url = paste(base.url,user,sep=""), config=credential) # make first api call
    }
    if (tmp$status==401){ # something went wrong: service unavail or bad authorization
      cat("not authorized, protected account\n")
      tweets <- NULL
    } else if (tmp$status==404){ # user not found
      cat("user not found\n")
      tweets <- NULL
    } else {
      dat <- content(tmp, as="text") # parse json returned
      
      # save raw JSON
      if (rawdata){
        tim <- Sys.time()
        tim <- gsub(" ","_",tim)
        write(dat, file=paste(datadir,"/usertweets/",user,"_",tim,".JSON",sep=""))
      }
      
      dat <- fromJSON(dat)
      t <- do.call(rbind,lapply(dat, function(x) parseTweetObj(x, timeline=TRUE))) # parse tweet objects returned
      tweets <- rbind(tweets, t) # store data for the first 200 more recent tweets from user
      
      # now we need to loop through the timeline by using the min tweet id returned each time
      # stop when no more data is available or we reach the limit (3200 tweets)
      if (nrow(tweets)>0){ # might be more tweets
        # count calls to occasionally check if rate limited
        while(nrow(t)>1){ # while results are returned, a result of length one is just the max_id tweet i.e. the max_id given is equal to the oldest tweet
          # should return 200 results each time, but we give ourselves a buffer just in case
          max_id <- as.character(tweets$id_str[nrow(tweets)]) # note the id of the oldest tweet already collected
          # check to make sure we have a query left
          rl <- checkRL("statuses", credential)
          remaining <- rl$resources$statuses[["/statuses/user_timeline"]]$remaining
          if (is.null(remaining)){
            rl <- checkRL("statuses", credential)
            remaining <- rl$resources$statuses[["/statuses/user_timeline"]]$remaining
          }
          if(is.null(remaining))
            remaining=0
          if (remaining<=4){
            cat("Sleeping for 15 min...starting at ", as.character(Sys.time()), "\n", sep="")
            Sys.sleep(60*15)
          }
          tmp <- GET(url = paste(base.url,user,"&count=200&max_id=",max_id,sep=""), config=credential) # get all data before this point, note the max_id is also returned

          # check to make sure status is OK, else sleep and retry
          if (tmp$status!=200){ # something went wrong: service unavail or bad authorization
            cat("bad results, trying again\n")
            Sys.sleep(15)
            tmp <- GET(url = paste(base.url,user,sep=""), config=credential) # make first api call
          }
          
          dat <- content(tmp, as="text") # parse json
          # save raw JSON
          if (rawdata){
            tim <- Sys.time()
            tim <- gsub(" ","_",tim)
            write(dat, file=paste(datadir,"/usertweets/",user,"_",tim,".JSON",sep=""))
          }
          dat <- fromJSON(dat)
          
          t <- do.call(rbind,lapply(dat, function(x) parseTweetObj(x, timeline=TRUE))) # parse tweet objects
          tweets <- rbind(tweets, t) # add to dataset
          tweets <- unique(tweets) # remove the duplicates
          cat(".")
        }
      } else {
        tweets <- NULL
      }
    }
  } else { # grab since provided id
    tweets <- matrix(NA, nr=0, nc=48) # to store data in
    tmp <- GET(url = paste(base.url,user,"&count=200&since_id=",since.id,sep=""), config=credential) # make first api call
    if (tmp$status==429){
      cat("Sleeping for 15 min...starting at ", as.character(Sys.time()), "\n", sep="")
      Sys.sleep(60*15)
      tmp <- GET(url = paste(base.url,user,"&count=200&since_id=",since.id,sep=""), config=credential)
    }
    
    if (tmp$status==401){ # something went wrong: service unavail or bad authorization
      cat("not authorized, protected account\n")
      tweets <- NULL
    } else if (tmp$status==404){ # user not found
      cat("user not found\n")
      tweets <- NULL
    } else {
      
      dat <- content(tmp, as="text") # parse json returned
      # save raw JSON
      if (rawdata){
        tim <- Sys.time()
        tim <- gsub(" ","_",tim)
        write(dat, file=paste(datadir,"/usertweets/",user,"_",tim,".JSON",sep=""))
      }
      dat <- fromJSON(dat)
      t <- do.call(rbind,lapply(dat, function(x) parseTweetObj(x, timeline=TRUE))) # parse tweet objects returned
      if (!is.null(t)){ # no new statuses since the last one we collected
        
        tweets <- rbind(tweets, t) # store data for the first 200 more recent tweets from user
        # make rest of the api calls (i.e. min returned id is still greater than since.id)
        while(nrow(t)>1){ 
          max_id <- as.character(tweets$id_str[nrow(tweets)]) 
          # check to make sure we have a query left
          rl <- checkRL("statuses", credential)
          remaining <- rl$resources$statuses[["/statuses/user_timeline"]]$remaining
          if (is.null(remaining)){
            rl <- checkRL("statuses", credential)
            remaining <- rl$resources$statuses[["/statuses/user_timeline"]]$remaining
          }
          if(is.null(remaining))
            remaining=0
          if (remaining<=4){
            cat("Sleeping for 15 min...starting at ", as.character(Sys.time()), "\n", sep="")
            Sys.sleep(60*15)
          }
          tmp <- GET(url = paste(base.url,user,"&count=200&max_id=",max_id,"&since_id=",since.id,sep=""), config=credential) 
          dat <- content(tmp, as="text")
          # save raw JSON
          if (rawdata){
            tim <- Sys.time()
            tim <- gsub(" ","_",tim)
            write(dat, file=paste(datadir,"/usertweets/",user,"_",tim,".JSON",sep=""))
          }
          dat <- fromJSON(dat)                       
          t <- do.call(rbind,lapply(dat, function(x) parseTweetObj(x, timeline=TRUE))) 
          tweets <- rbind(tweets, t) 
          tweets <- unique(tweets)
          cat(".")
        }
      } else {
        tweets <- NULL
      }
    }
  }
  if (!is.null(tweets)){
    # transform tweet datetime into nicer format 
    tweets$created_at <- strptime(gsub("\\+0000 ","",tweets$created_at), format="%a %b %d %H:%M:%S %Y")
    tweets$text <- cleanText(tweets$text)
    tweets$user_description <- cleanText(tweets$user_description)
    tweets <- unique(tweets)
    # check again based on unique identifier of tweet_id_str
    inds <- unique(tweets$id_str)
    if (length(inds)<nrow(tweets)){
      touse <- match(as.character(inds), as.character(tweets$id_str))
      tweets <- tweets[touse,]
    }
    # remove any funny character that will mess up data entry
  } 
  #return(list(remaining, tweets)) # for testing
  return(tweets)
}




### FUNCTION TO GET USER SOCIAL TIES
# we careful with this one because it is very easy to get rate limited - 15 requests/15 min 
# one call returns up to 5000 ids
# Updated January 2015 to collect both friends and followers
getUserEgonet <- function(user,is.ID=TRUE,out.only=TRUE,credential=NULL){
  
  # make empty vectors to store friends and followers ids
  friend_ids <- NULL
  follower_ids <- NULL
  
  # First not base urls for REST API to retrieve social ties
  base.url.followers <- "https://api.twitter.com/1.1/followers/ids.json?"
  base.url.friends <- "https://api.twitter.com/1.1/friends/ids.json?"
  
  if (is.ID){ # determine means of identifying user - note userID is the default
    ui <- "&user_id="
  } else {
    ui <- "&screen_name="
  }
  
  # Check rate limit
  rl <- checkRL("friends", credential)
  rl <- rl$resources$friends$`/friends/ids`$remaining
  
  # Sleep if less than 2 queries are left
  if (rl < 2){
    cat("\n  Rate limited, sleeping for 15min ... starting at", as.character(Sys.time())," \n")
    Sys.sleep(60*15)
  }   
  
  #### Getting friends
  cat("\n Collecting outgoing relationships...")
  # make api call for friends and parse results
  tmp1 <- GET(url = paste(base.url.friends,"cursor=-1",ui,user,sep=""), config=credential)
  dat1 <- content(tmp1, as="text") 
  dat1 <- fromJSON(dat1)
  
  if(is.null(dat1$error)){
    
    if (is.null(dat1$errors)){
      
      friend_ids <- c(friend_ids, dat1$ids) # get list of follower ids
      
      # if less than 5000 results were retrieved we dont need to get any more
      # we can check this if the cursor changes
      cursor <- dat1$next_cursor_str
      while(cursor!=0){
        tmp1 <- GET(url = paste(base.url.friends,"cursor=",cursor,ui,user,sep=""), config=credential)
        dat1 <- content(tmp1, as="text") 
        dat1 <- fromJSON(dat1)
        friend_ids <- c(friend_ids, dat1$ids)
        cursor <- dat1$next_cursor_str
        # check to see if we were rate limited
        # Check rate limit
        rl <- checkRL("friends", credential)
        rl <- rl$resources$friends$`/friends/ids`$remaining
        
        # Sleep if less than 2 queries are left
        if (rl < 1){
          cat("\n  Rate limited, sleeping for 15min ... starting at", as.character(Sys.time())," \n")
          Sys.sleep(60*15)
        } 
        cat(".")
      } 
      cat("done. \n")
      
      # Check rate limit
      rl <- checkRL("followers", credential)
      rl <- rl$resources$followers$`/followers/ids`$remaining
      
      # Sleep if less than 2 queries are left
      if (rl < 2){
        cat("\n  Rate limited, sleeping for 15min ... starting at", as.character(Sys.time())," \n")
        Sys.sleep(60*15)
      }   
    }
  }
  
  #### Getting followers
  if (!out.only){
    cat("\n Collecting incoming relationships...\n")
    
    tmp2 <- GET(url = paste(base.url.followers,"cursor=-1",ui,user,sep=""), config=credential)
    dat2 <- content(tmp2, as="text") 
    dat2 <- fromJSON(dat2)
    
    if(is.null(dat2$error)){
      if (is.null(dat1$errors)){
        
        
        follower_ids <- c(follower_ids, dat2$ids)
        
        # if less than 5000 results were retrieved we dont need to get any more
        # we can check this if the cursor changes
        cursor <- dat2$next_cursor_str
        
        while(cursor!=0){
          tmp2 <- GET(url = paste(base.url.followers,"cursor=",cursor,ui,user,sep=""), config=credential)
          dat2 <- content(tmp2, as="text") 
          dat2 <- fromJSON(dat2)
          follower_ids <- c(follower_ids, dat2$ids)
          # update cursor
          cursor <- dat2$next_cursor_str
          # check to see if we might get rate limited
          # Check rate limit
          rl <- checkRL("followers", credential)
          rl <- rl$resources$followers$`/followers/ids`$remaining
          
          # Sleep if less than 2 queries are left
          if (rl < 1){
            cat("\n  Rate limited, sleeping for 15min ... starting at", as.character(Sys.time())," \n")
            Sys.sleep(60*15)
          } 
          cat(".")
        } 
        cat("done. \n")
      }
    }
  }
  
  
  # note capture time
  captureTime <- format(Sys.time(), format = "%Y-%m-%d_%H-%M-%S", tz = "UTC", usetz = TRUE)
  
  # transform social tie data into an edgelist
  outTies <- matrix(NA, nr=0, nc=4)
  inTies <- matrix(NA, nr=0, nc=4)
  
  if (!is.null(friend_ids) & length(friend_ids)>0)
    outTies <- cbind(rep(user), rep(user), friend_ids, rep(as.character(captureTime)))
  if (!is.null(follower_ids) & length(follower_ids)>0)
    inTies <- cbind(rep(user), follower_ids, rep(user), rep(as.character(captureTime)))
  
  res <- rbind(outTies, inTies)
  colnames(res) <- c("ego_id", "tail_id", "head_id","collected_datetime")
  
  if (nrow(res)==0)
    res <- "Not authorized."
  return(res)
  
}

