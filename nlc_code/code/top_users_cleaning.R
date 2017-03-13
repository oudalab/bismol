## cleaning and organizing data on top 100 Twitter users

setwd("C:/Users/ninac2/Dropbox/")

topUsers<-read.csv("top_100_twitter_users.csv")
topUsers<-as.character(topUsers[,1])

topUsers<-topUsers[-c(grep("[0-9]", topUsers, perl=TRUE))]
topUsers<-topUsers[grep("@", topUsers)]

topUsers<-as.data.frame(topUsers)

topUsers<-apply(topUsers,1, function(x) unlist(strsplit(x, "@"))[2])

topUsers<-as.data.frame(topUsers)
topUsers<-apply(topUsers, 1, function(x) paste0("@",x))

write.csv(as.data.frame(topUsers), "top_100_twitter_users.csv")


