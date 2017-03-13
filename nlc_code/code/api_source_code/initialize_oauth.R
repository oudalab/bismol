################################################################################################
# 
# Script to authenticate and save OAuth object for Twitter API
# 
################################################################################################

# Last update 07.16.15 by Emma S. Spiro

#### load neccesary packages to create and store authentication with Twitter API ####
library(twitteR)
library(ROAuth)
library(httr)
library(methods)
library(base64enc)

## ADJUST TO LOCAL PROJECT
workingDir <- "C:/Users/ninac2/Dropbox/miscarriage_project/"
projectDir <- "C:/Users/ninac2/Dropbox/miscarriage_project/"

####################### Authentification #####################


# Set up the API keys and secret (THIS IS APP AND PROJECT SPECIFIC)
api_key <- "K9hdoAOqZLTRvgkVLJz9IhMiX"
api_secret<- "EJgiCTeV7MWzsLquNk9vQMk6cLEu0Fslz7yKdiQHq1hofB4hFr"
acc_token<- "419220939-acWVGs8QC6GEgZXbZzvvKzV4QqohduFTmdh9jVHm"
acc_token_secret<- "2kyY6AYVZSJhmoAE2NDegPVGS52LVi3UsFBjjWjFgVM4U"

# Store the Twitter API oauth locations
reqURL <- "https://api.twitter.com/oauth/request_token"
accessURL<- "https://api.twitter.com/oauth/access_token"
authURL <- "https://api.twitter.com/oauth/authorize"

# Create the credential
twitCred <- OAuthFactory$new(consumerKey=api_key,
                             consumerSecret=api_secret,
                             requestURL=reqURL,
                             accessURL=accessURL,
                             authURL=authURL)

# Compete the handshake
# This will result in a URL, click on the URL, choose the authorize app option
# copy the PIN and enter it into the R console.
twitCred$handshake()

# Choose [1] "Using direct authentication"
# Use a local file to cache OAuth access credentials between R sessions?
# 2: No
setup_twitter_oauth(api_key, api_secret, access_token=acc_token, access_secret=acc_token_secret)

# And resused in continuous data collection
twitter.app <- oauth_app("twitter",key=api_key, 
                         secret=api_secret)


# Fill in the access tokens from the app page on dev.twitter.com
user.signature <- sign_oauth1.0(twitter.app, 
                                token = acc_token, 
                                token_secret = acc_token_secret)

# Save credential
save(user.signature, file=paste(projectDir, "/user_sig_roauth.rdata",sep=""))

# test to see if this authentification has worked 
url <- "https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=emmaspiro"
#url <- "https://api.twitter.com/1.1/statuses/user_timeline.json?user_id=42734694"


tmp <- GET(url = url, config=user.signature) 
dat <- content(tmp, as="text")
dat

