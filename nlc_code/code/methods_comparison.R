## ================================================================================================
##
## This R code replicates method of auto-detecting Twitter user demographics 
## Code examines: reliability and accuracy of methods gathered for demographic detection project
## 
## ================================================================================================

## Author: Nina Cesare  Date: 10/26/16



workingDir<-"C:/Users/ninac2/Dropbox/RWJF Project/demographic_detection_bib/analysis"
setwd(workingDir)

#install.packages(c("caret","corelearn","e1071","glmnet","lars"))

library(pacman)
p_load(caret)
p_load(kernlab)
p_load(CORElearn)
p_load(e1071)
p_load(glmnet)
p_load(lars)
p_load(rjson)
p_load(httr)
p_load(RCurl)
p_load(twitteR)
p_load(streamR)
p_load(ROAuth)
p_load(RCurl)
p_load(grDevices)

source("code/api_source_code/parsing_functions.R")
source("code/api_source_code/get_user_timeline.R")
source("code/api_source_code/get_user_info.R")
## User signature created using /code/api_source_code/initialize_oauth.R
load("C:/Users/ninac2/Dropbox/RWJF Project/demographic_detection_bib/analysis/data/user_sig_roauth.rdata")
load("C:/Users/ninac2/Dropbox/RWJF Project/demographic_detection_bib/analysis/nina_sig_roauth.rdata")



###### Authenticate connection for using TwitteR ##########

###### Authenticate API connection ######

## Twitter credentials for streamR and twitteR authentication
## Twitter app = Miscarriage project 
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



############ Loading ground truth data ####################

## temp gender data (from Liu and Ruths 2013)

#lr_file <- "data/ground_truth_temp/LiuRuthsMicrotext/labels.json"
#lr_gender <- fromJSON(paste(readLines(lr_file), collapse=""))
#lr_gender <-do.call("rbind", lr_gender)

# gender user metadata
#gender_users<-get_user_info(rownames(lr_gender), credential=user.signature, datadir = "", rawdata = FALSE)
#gender_users<-do.call("rbind", gender_users)

#gender_users<-gender_users[-which(gender_users$note=="user not found"),]

#write.csv(gender_users, "data/gender_users.csv", row.names=FALSE)

#gender_users<-read.csv("data/gender_users.csv", stringsAsFactors=FALSE)



## gender users from Kaggle (full profiles validated by three Crowdflower users)
gender_users<-read.csv("C:/Users/ninac2/Dropbox/RWJF Project/kaggle_data/gender-classifier-DFE-791531.csv", stringsAsFactors = FALSE)

gender_users_new<-twListToDF(lookupUsers(gender_users$name))
gender_users_new<-gender_users_new[,-c(1,7,8)]
names(gender_users_new)[8]<-"name"

gender_users<-merge(gender_users, gender_users_new, by="name", all=TRUE)

gender_users_part<-gender_users[-which(is.na(gender_users$profileImageUrl) | is.na(gender_users$profileimage)),]

write.csv(gender_users_part, "C:/Users/ninac2/Dropbox/RWJF Project/kaggle_data/gender-classifier-DFE-791531_1-31-17.csv")

################### Sloan's PlOS One Age Detection Article ####################
#########################  Characteristic: AGE ################################

## This method relies on inference via user descriptions

# Going to remove weird characters that could be between words prior to strsplit
gender_users$description<-gsub("_", " ", gender_users$description)
gender_users$description<-gsub("...", " ", gender_users$description, fixed=TRUE)
gender_users$description<-gsub("-", " ", gender_users$description)

## age keywords: age, aged, I'm, I am, born, born in, yrs, yrs old, years, years old

ageIDX1<-grep("age", gender_users$description, ignore.case = TRUE)
ageIDX2<-grep("aged", gender_users$description, ignore.case=TRUE)
ageIDX3<-grep("I'm .* years", gender_users$description, ignore.case=TRUE, perl=TRUE)
ageIDX4<-grep("I am .* years", gender_users$description, ignore.case=TRUE, perl=TRUE)
ageIDX5<-grep("born", gender_users$description, ignore.case=TRUE)
ageIDX6<-grep("born in", gender_users$description, ignore.case=TRUE)
ageIDX7<-grep("yrs", gender_users$description, ignore.case=TRUE)
ageIDX8<-grep("yrs old", gender_users$description, ignore.case=TRUE)
ageIDX9<-grep("years", gender_users$description, ignore.case=TRUE)
ageIDX10<-grep("years old", gender_users$description, ignore.case=TRUE)

age_idx<-unique(c(ageIDX1,ageIDX2,ageIDX5,ageIDX6,ageIDX7,ageIDX8,ageIDX9,ageIDX10))

gender_users_part<-gender_users[age_idx,]

## Age exclusion terms: for''years as' 'spent''years working' 'years in' Any of the post-integer terms listed in Table 4 when followed by 'son', 'daughter

removeIDX1<-grep("years as", gender_users_part$description, ignore.case=TRUE)
removeIDX2<-grep("years working", gender_users_part$description,ignore.case=TRUE)
removeIDX3<-grep("years spent", gender_users_part$description,ignore.case=TRUE)
removeIDX4<-grep("years as", gender_users_part$description,ignore.case=TRUE)
removeIDX5<-grep("years .* son", gender_users_part$description, ignore.case=TRUE, perl=TRUE)
removeIDX6<-grep("years .* daughter", gender_users_part$description, ignore.case=TRUE, perl=TRUE)

removeIDX<-unique(c(removeIDX1,removeIDX2,removeIDX3,removeIDX4,removeIDX5,removeIDX6))
gender_users_part<-gender_users_part[-removeIDX,]


## Automatically detect actual age within the description
unlist(strsplit(gender_users_part$description[409], " "))[which(unlist(strsplit(gender_users_part$description[409], " "))=="years")-1]
ages<-sapply(gender_users_part$description, function(x) unlist(strsplit(x, " "))[which(unlist(strsplit(x, " "))=="years")-1])
gender_user_part<-cbind(gender_users_part, ages)

## Explore age ditsribution and comprehensiveness 


############## Kosinski's PNAS Facebook article ##################


# dimensionality reduction in 'likes' (which we'll consider analogous to verified follows)
# Can maybe collect top 100 verified users? (http://twittercounter.com/pages/100?vt=1&utm_expid=102679131-111.l9w6V73qSUykZciySuTZuA.1&utm_referrer=https%3A%2F%2Fwww.google.com%2F)

topUsers<-read.csv("data/top_100_twitter_users.csv", stringsAsFactors=FALSE)
topUsers<-twListToDF(lookupUsers(topUsers$topUsers))

## link top users to accounts 
## not sure how scalable tihs is given that we'll need to collect follower data
## Although I guess we could get the nets of the celebs instead...
nets<-get_user_network(gender_users$id_str[1:5], credential=user.signature, out_only=TRUE)


lapply(nets, function(x) intersect(x[,3], topUsers))

## Age - linear model, 10 fold cross validation 
### create dummy variable with 
## linear modeling with test set
folds<-createFolds(y=dat$age, k=10, list=TRUE, returnTrain = TRUE)
sapply(folds, length) #what do each of our slices look like?
##



###################### Zagheni (using Face++)  #####################
## Gender, age,race
gender_users_part$profileImageUrl<-gsub("_normal", "", gender_users_part$profileImageUrl)


## Load Face++ API tokens 
my_api_key<- "462c408eb5b21dde8c375847ee33e419"
my_api_secret<- "XEwYlaFcYq8qrujh8nPw8fAYeoHmu-tF"

#function to feed photos to API
figure_details<- function(pic_url){  
  url_for_request<- paste("http://apius.faceplusplus.com/v2/detection/detect?api_key=",my_api_key,"&api_secret=",my_api_secret,"&url=",pic_url,"&attribute=age%2Cgender%2Crace%2Csmiling%2Cpose%2Cglass",sep="")
  
  return(fromJSON(getURL(url_for_request)))
}

picInfo<-vector("list", 15000)
picInfo2<-vector("list", 15000)


#ptm <- proc.time()
for(i in 4559:length(gender_users_part$profileImageUrl[1:15000])){
  picInfo2[[i]]<-figure_details(gender_users_part$profileImageUrl[i])
  print(paste("Got picture ", i,"!", sep=""))
}
#ptm <- proc.time()

#save(picInfo, file="gender_face_info.Rdata")

### will re-parse with lapply

picParsing<-function(item){
  if(length(item$face)==1){
    race<-item$face[[1]]$attribute$race$value[1]
    race_conf<-item$face[[1]]$attribute$race$confidence[1]
  }
  if(length(item$face)>1){
    faces<-NULL
    confs<-NULL
    for (j in 1:length(item$face)){
      face<-item$face[[j]]$attribute$race$value
      faces<-c(faces, face)
      conf<-item$face[[j]]$attribute$race$confidence
      faces<-c(faces, face)
      confs<-c(confs, conf)
      if(length(table(faces))==1 & mean(confs)>=80){
        race<-item$face[[1]]$attribute$race$value
        race_conf<-mean(confs)
      }
      else{
        race<-NA
        race_conf<-NA
      }
    }
  }
  if(length(item$face)<1){
    race<-NA
    race_conf<-NA
  }
  row<-c(paste(race,race_conf, collapse=","))
  return(row)
}

race_list<-unlist(lapply(picInfo, function(x) picParsing(x)))

race<-unlist(lapply(race_list, function(x) unlist(strsplit(x, " "))[1]))
conf<-unlist(lapply(race_list, function(x) unlist(strsplit(x, " "))[2]))


picDat<-do.call("rbind", picInfo)
picDat<-cbind(picDat, race, conf)


################ Longley's complex name parsing article ############

## reduce to users
## remove users with device reported geotagging error 

## Users with a space in their names:
## 1. remove honorifics/suffixes
## 2. Tokenize names 
## 3. Database used to determine whether name is first or surname 


## Users with no space in their names:
## 1. Search for first and surname string matches within name
## 2. A name is considered invalid if both a first and surname are not identified

## age: frequency of names within 5 year bands 
## gender: proportion within 

## There are a lot of name-matching apps, but 
filenames<-list.files("data/names")
#use files 62-end (going to assume that no one over 78 - the average US life span - is on Twitter)


nameDat<-NULL
for(i in 62:length(filenames)){
  tab<-read.table(paste0("data/names/", filenames[i]))
  subDat<-NULL
  for(j in 1:length(tab[,1])){
    row<-c(unlist(strsplit(as.character(tab[j,1]), ",")))
    subDat<-rbind(subDat, row)
  }
  year<-gsub(".txt", "", filenames[i])
  year<-gsub("yob", "", year)
  row<-cbind(subDat, rep(year,dim(subDat)[1]))
  nameDat<-rbind(nameDat, row)
  paste0("Done with file ", i, "!")
}

#lapply(tab, function(x) unlist(strsplit(x, ",")))

nameDat<-as.data.frame(nameDat)
names(nameDat)<-c("name", "gender", "count", "year")
nameDat$count<-as.numeric(as.character(nameDat$count))
nameDat$year<-as.numeric(as.character(nameDat$year))


genderFreq<-aggregate(nameDat$count, by=list(name=nameDat$name, gender=nameDat$gender), FUN=sum)
head(genderFreq)
names(genderFreq)[3]<-"frequency"


## If a name is both male and female, then we have to find out which value is greater..
mysteryNames<-intersect(genderFreq$name[which(genderFreq$gender=="M")],genderFreq$name[which(genderFreq$gender=="F")])

genderFreq_reduce<-genderFreq
genderFreq_reduce$name<-as.character(genderFreq_reduce$name)
genderFreq_reduce$gender<-as.character(genderFreq_reduce$gender)

for(i in 1:length(mysteryNames)){
  index<-which(genderFreq_reduce$name==mysteryNames[i])
  remove_index<-which(genderFreq_reduce$frequency[c(index)]==min(genderFreq_reduce$frequency[c(index)]))
  if(length(remove_index)==1){
    if(remove_index==1){
      genderFreq_reduce$frequency[index[1]]<-0  #for the less frequent user, replace with zero and remove
    }
    if(remove_index==2){
      genderFreq_reduce$frequency[index[2]]<-0
    }
  }
  else{
    print(paste0("Name ", mysteryNames[i], " has no gender"))
    genderFreq_reduce<-genderFreq_reduce[-c(index),]
  }
}

## just remove the names that have no gender

genderFreq_reduce<-genderFreq_reduce[-which(genderFreq_reduce$frequency==0),]
genderFreq_reduce$name_lower<-tolower(genderFreq_reduce$name)


## Saved the datafile that resulted from all this: 
genderFreq_reduce<-read.csv("data/name_gender_freq_ssa.csv", stringsAsFactors=FALSE)

gender_users$name_clean<-tolower(gender_users$name)
gender_users$name_clean<-unlist(lapply(gender_users$name_clean, function(x) gsub("[[:punct:]]", "", x)))
## remove punctuation

suffix<-c("mr ", "mr_", "mr-",
          "mrs ", "mrs_", "mrs-",
          "ms ", "ms_", "ms-",
          "miss.", "miss ", "miss_", "miss-",
          "mx ", "mx_", "mx-",
          "sir ", "sir_", "sir-",
          "gentleman ", "gentleman_", "gentleman-",
          "sir ", "sire_", "sire-",
          "mistress ", "mistress_", "mistress-",
          "madame ", "madame_", "madame-",
          "dame ", "dame_", "dame-",
          "lord ", "lord_", "lord-",
          "lady ", "lady_", "lady-",
          "esq ", "esq_", "esq-",
          "dr ", "dr_", "dr-",
          "professor ", "professor_", "professor-",
          "prof ", "prof_", "prof-",
          "reverend ", "reverend_", "reverend-",
          "reverend ", "reverend_", "reverend-",
          "reverend ", "reverend_", "reverend-",
          "rev ", "rev_", "rev-",
          "fr ", "fr_", "fr-",
          "pr ", "pr_", "pr-",
          "br ", "br_", "br-",
          "sr ", "sr_", "sr-",
          "jr ", "jr_", "jr-",
          " ma", " jd", "phd", "dr "," jd", "m.d.", " do", " dc", "pharm d", "mfa")



for(i in 1:length(suffix)){
  gender_users$name_clean<-gsub(suffix[i], "", gender_users$name_clean, fixed=TRUE)
}
          


## remove less common names

quantile(genderFreq_reduce$frequency)
genderFreq_reduce_part<-genderFreq_reduce[which(genderFreq_reduce$frequency>=222),]


genderFreq_reduce_part$twitter_index<-unlist(lapply(genderFreq_reduce_part$names_lower, function(x) paste(grep(x, gender_users$name_clean), collapse=",")))

genderFreq_reduce_part<-genderFreq_reduce_part[which(genderFreq_reduce_part$twitter_index!=""),]
## what is returned: where that name matches the gender_users
## what is needed: what the gender associated with that name is.




################ Mislove/Chang data matching or adjusted data matching strategy ##############
## Gender, ethnicity

## Detecting gender using first name (2010 Social Security Administration)

## adjusted data matching using census.data model described in Chang et al (2010)
## Bayesian multinomial logit model https://cran.r-project.org/web/packages/BayesLogit/BayesLogit.pdf





########## Alowibdi (language independent gender prediction ########################

## 5 color features in total
## background color
## Text color
## link color
## Sidebar fill color
## sidebar border color


## pull more detailed metdata to get additional color metadata 
## will need to merge this back in with the kaggle data
gender_dat<-read.csv("C:/Users/ninac2/Dropbox/RWJF Project/kaggle_data/gender-classifier-DFE-791531_1-31-17.csv", stringsAsFactors=FALSE)
uInfo<-get_user_info(gender_dat$id, credential = user.signature, rawdata = FALSE, datadir="")
gender_users<-do.call("rbind", uInfo)
gender_users<-merge(gender_users, gender_dat, by="id")

## we don't want to work with brand or unknown data
gender_users$gender_new<-as.character(gender_users$gender)
gender_users$gender_new[gender_users$gender=="brand"]=NA
gender_users$gender_new[gender_users$gender=="unknown"]=NA

gender_users_noNA<-gender_users[which(!is.na(gender_users$gender_new)),] 
gender_users_noNA<-gender_users_noNA[-which(gender_users_noNA$gender_new==""),]
gender_users_noNA$link_color<-paste0("#", gender_users_noNA$link_color)
gender_users_noNA<-gender_users_noNA[-which(gender_users_noNA$default_profile==TRUE),]

### removing default profiles 


### creating RBG colors

color_convert<-function(color){
  rgb<-paste(col2rgb(paste0("#", color))[,1], collapse="")
  return(rgb)
}


gender_users_noNA$profile_background_color_new<-unlist(lapply(as.character(gender_users_noNA$profile_background_color), function(x) color_convert(x)))
gender_users_noNA$profile_link_color_new<-unlist(lapply(as.character(gender_users_noNA$profile_link_color), function(x) color_convert(x)))
gender_users_noNA$profile_sidebar_border_color_new<-unlist(lapply(as.character(gender_users_noNA$profile_sidebar_border_color), function(x) color_convert(x)))
gender_users_noNA$profile_sidebar_fill_color_new<-unlist(lapply(as.character(gender_users_noNA$profile_sidebar_fill_color), function(x) color_convert(x)))
gender_users_noNA$profile_text_color_new<-unlist(lapply(as.character(gender_users_noNA$profile_text_color), function(x) color_convert(x)))
# gender users name ngram (without phonemes)
# gender users name ngram (with phonemes )


## things I'm testing
gender_users_noNA$screen_name<-as.character(gender_users_noNA$screen_name)
gender_users_noNA$name_vowel<-unlist(lapply(gender_users_noNA$screen_name, function(x) name_vowel(x)))
gender_users_noNA$description_new<-nchar(gender_users_noNA$description.x)


name_vowel<-function(name){
  if(nchar(name>0)){
    letter<-unlist(strsplit(name, ""))[length(unlist(strsplit(name, "")))]
    if(letter=="a"|letter=="e"|letter=="i"|letter=="o"|letter=="u"|letter=="y"){
      return(1)
    }
    else{
      return(0)
    }
  }

  else{
    return(0)
  }
}

### Color quantization 
#https://www.r-bloggers.com/color-quantization-in-r/
## not sure how they're going about color quantization here


### Modeling
### https://cran.r-project.org/web/packages/CORElearn/CORElearn.pdf
set.seed(125)
ntrain <- round(dim(gender_users_noNA)[1]*0.8) # number of training examples
tindex <- sample(1:dim(gender_users_noNA)[1],ntrain) # indices of training samples

train<-gender_users_noNA[tindex,]
test<-gender_users_noNA[-tindex,]

## colors as HEX codes 
colorMod_1<-CoreModel(as.factor(gender_new)~profile_background_color+profile_link_color+profile_sidebar_border_color+profile_sidebar_fill_color+profile_text_color, data=train, model="bayes")
colorPred_1<- predict(colorMod_1, test, type="both") # prediction on testing set

## Colors as RGB values 
colorMod_2<-CoreModel(as.factor(gender_new)~profile_background_color_new+profile_link_color_new+profile_sidebar_border_color_new+profile_sidebar_fill_color_new+profile_text_color_new, data=train, model="bayes")
colorPred_2<- predict(colorMod_2, test, type="both") # prediction on testing set

## Colors as RGB values AND profile description length
colorMod_3<-CoreModel(as.factor(gender_new)~profile_background_color_new+profile_link_color_new+profile_sidebar_border_color_new+profile_sidebar_fill_color_new+profile_text_color_new+description_new, data=train, model="bayes")
colorPred_3<- predict(colorMod_3, test, type="both") # prediction on testing set

## Colors as RGB values AND name-vowel distinction
colorMod_4<-CoreModel(as.factor(gender_new)~profile_background_color_new+profile_link_color_new+profile_sidebar_border_color_new+profile_sidebar_fill_color_new+profile_text_color_new+name_vowel, data=train, model="bayes")
colorPred_4<- predict(colorMod_4, test, type="both") # prediction on testing set

## Colors as HEX values AND name-vowel distinction 
colorMod_4b<-CoreModel(as.factor(gender_new)~profile_background_color_new+profile_link_color+profile_sidebar_border_color+profile_sidebar_fill_color+profile_text_color+name_vowel, data=train, model="bayes")
colorPred_4b<- predict(colorMod_4, test, type="both") # prediction on testing set

y <- as.factor(test$gender_new)
predictions_1 <- as.factor(colorPred_1$class)
predictions_2 <- as.factor(colorPred_2$class)
predictions_3 <- as.factor(colorPred_3$class)
predictions_4 <- as.factor(colorPred_4$class)
predictions_4b <- as.factor(colorPred_4b$class)


precision <- posPredValue(predictions_4b, y)
recall <- sensitivity(predictions_4b, y)
F1 <- (2 * precision * recall) / (precision + recall)
tab<-table(y, predictions_4b)
confusionMatrix(tab)

## for all colors, RGB & profile description length
#precision=0.58
#recall=0.63
#F1=0.61

## for just colors in hex
#precision=0.749
#recall=0.624
#F1=0.681
#Accuracy=0.67

## 5-fold cross validation with just hex colors 

#Randomly shuffle the data
yourData<-yourData[sample(nrow(yourData)),]

#Create 10 equally size folds
folds <- cut(seq(1,nrow(gender_users_noNA)),breaks=5,labels=FALSE)

for(i in 1:5){
  #Segement your data by fold using the which() function 
  testIndexes <- which(folds==i,arr.ind=TRUE)
  testData <- gender_users_noNA[testIndexes, ]
  trainData <- gender_users_noNA[-testIndexes, ]
  colorMod<-CoreModel(as.factor(gender_new)~profile_background_color+profile_link_color+profile_sidebar_border_color+profile_sidebar_fill_color+profile_text_color, data=train, model="bayes")
  colorPred<- predict(colorMod_1, test, type="both") # prediction on testing set

  ## Colors as RGB values AND profile description length
  colorMod_3<-CoreModel(as.factor(gender_new)~profile_background_color_new+profile_link_color_new+profile_sidebar_border_color_new+profile_sidebar_fill_color_new+profile_text_color_new+description_new, data=train, model="bayes")
  colorPred_3<- predict(colorMod_3, test, type="both") # prediction on testing set
  
  
  y <- as.factor(test$gender_new)
  predictions_1 <- as.factor(colorPred_1$class)
  predictions_2 <- as.factor(colorPred_2$class)
  predictions_3 <- as.factor(colorPred_3$class)
  
  
  precision <- posPredValue(predictions_2, y)
  recall <- sensitivity(predictions_2, y)
  F1 <- (2 * precision * recall) / (precision + recall)

}


## Adding name phoneme n-grams to existing color prediction methods
#Detection of first names
#Removal or leading and training white space
#deletion of last names
#deletion of numbers
#deletion of punctuation
#deletion of stopwords 
#identification of phonemes in the first names
#generate n-grams of phonemes sequences
stopwords_name<-c(stopwords("en"), suffix)
stopwords_name<-gsub(" ", "", stopwords_name)

gender_users_noNA$new_name<-stripWhitespace(as.character(gender_users_noNA$name.x))



convert_names<-function(name){
  name_new<-name
  if(Encoding(name_new)=="UTF-8"){
    name_new<-iconv(name_new, "UTF-8", "ASCII", sub="")
  }
  name_new<-tolower(stripWhitespace(as.character(name_new)))
  name_new<-sub("0+", "", name_new)
  name_new<-sub("1+", "", name_new)
  name_new<-sub("2+", "", name_new)
  name_new<-sub("3+", "", name_new)
  name_new<-sub("4+", "", name_new)
  name_new<-sub("5+", "", name_new)
  name_new<-sub("6+", "", name_new)
  name_new<-sub("7+", "", name_new)
  name_new<-sub("8+", "", name_new)
  name_new<-sub("9+", "", name_new)
  name_new<-removePunctuation(name_new)
  if(length(unlist(strsplit(name_new, " ")))>1){
    name_new<-strsplit(name_new, " ")[[1]][-length(unlist(strsplit(name_new, " ")))]
    name_new<-unlist(name_new)[!(unlist(name_new) %in% stopwords_name)]
  }
  if(length(name_new)==0){
    name_new<-NA
  }
  return(name_new)
}


gender_users_noNA$name_new<-NA 

# loop to view progress & troubleshoot
for(i in 1:length(gender_users_noNA$name.x)){
  gender_users_noNA$name_new[i]<-convert_names(gender_users_noNA$name.x[i])
  print(paste0("Done with user ", i, "!"))
}



gender_users_noNA$name_vowel<-unlist(lapply(gender_users_noNA$name_new, function(x) name_vowel(x)))

vowels<-NULL
for(i in 1:length(gender_users_noNA$name.x)){
  vowels[i]<-name_vowel(gender_users_noNA$name_new[i])
  print(paste0("Done w/user ", i, "!"))
}

############ Mueller: Developing classifier based on name characteristics ###########

## Of syllables (female = more, male=less )
## Number of consonants (male = more consonants)
## number of vowels (female = more vowels)
## vowel brightness (females = brighter vowels)
## ending character (female=vowel, male=consonant)
## number of boba or kiki consonants

## Constructed a logistic regression with this classifier






############# Vicente: Gender classification using unstructured information ###########


## feature extraction process 
## read user and scream name - find names in user name and screen name
## match gender to names if found 
## if not found, remove vowels and leet speak

## leet speak
# 3=e; 1=l; 0=o; 7=t; 4=a; 6=g; $=s

## for users whose gender is found: 
## whether case is relevant 
## whether the beginning and end separation (unclear what beginning separation means)
## Position: whether the name appears at beginning of name

## lazy versus greedy feature extraction 
## found that fuzzy c-means clustering with greedy features works best



############# Bergsma: clustering fist, last and user-provided locations #############

































################################## SCRATCH ############################
################### A Primer on Machine Learning in R #################


## Methods: SVM classification 
svm_model <- svm(Species ~ ., data=iris)
summary(svm_model)


## Methods: Naive Bayes Decision Tree (https://www.r-bloggers.com/a-brief-tour-of-the-trees-and-forests/)

frmla = Metal ~ OTW + AirDecay + Koc

## Modified balanced winnow neural network

## Fuzzy c-means clustering (https://en.wikibooks.org/wiki/Data_Mining_Algorithms_In_R/Clustering/Fuzzy_Clustering_-_Fuzzy_C-means)

cmeans(x, centers, iter.max = 100, verbose = FALSE,
       dist = "euclidean", method = "cmeans", m = 2,
       rate.par = NULL, weights = 1, control = list())

print(fclust)

## Data matching (direct matching, Baysian Matching)

## Facial recognition (Face++, can't use other propriety tools if someone doesn't release them)


###################### Classifying Age #####################

# Ridge regression 
data(longley)
x <- as.matrix(longley[,1:6])
y <- as.matrix(longley[,7])
# fit model
fit <- glmnet(x, y, family="gaussian", alpha=0, lambda=0.001)
# summarize the fit
summary(fit)
# make predictions
predictions <- predict(fit, x, type="link")
# summarize accuracy
rmse <- mean((y - predictions)^2)
print(rmse)

# load the package
library(glmnet)
# load data
data(longley)
x <- as.matrix(longley[,1:6])
y <- as.matrix(longley[,7])
# fit model
fit <- glmnet(x, y, family="gaussian", alpha=0, lambda=0.001)
# summarize the fit
summary(fit)
# make predictions
predictions <- predict(fit, x, type="link")
# summarize accuracy
rmse <- mean((y - predictions)^2)
print(rmse)



## LASSO regression 

# load data
data(longley)
x <- as.matrix(longley[,1:6])
y <- as.matrix(longley[,7])
# fit model
fit <- lars(x, y, type="lasso")
# summarize the fit
summary(fit)
# select a step with a minimum error
best_step <- fit$df[which.min(fit$RSS)]
# make predictions
predictions <- predict(fit, x, s=best_step, type="fit")$fit
# summarize accuracy
rmse <- mean((y - predictions)^2)
print(rmse)



################# Classifying Race/Ethnicity ################


