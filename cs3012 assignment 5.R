#Author: Aoife Tiernan
#Last updated: 21/11/2017

#install the necessary packages
library(jsonlite)
library(httpuv)
library(httr)
library(dplyr)
library(tidyverse)


#Select github as the endpoint
oauth_endpoints("github")


#Enter the details for my personal github application
myapp <- oauth_app(appname = "AoifeTiernanCS3012",
                   key = "b48eac03318fa39aa787",
                   secret = "b38c1c62e04b79152a3514bbac4b4a7fd1f6cde7")


#Set and get my github token 
githubToken <- oauth2.0_token(oauth_endpoints("github"), myapp)
getToken <- config(token = githubToken)



#Get current users followers
getFollowers <- function(username)
{
  i <- 1
  x <- 1
  followersDF <- data_frame()
  while(x!=0)
  {
    followers <- GET( paste0("https://api.github.com/users/", username, "/followers?per_page=100&page=", i))
    followersContent <- content(followers)
    currentFollowersDF <- lapply(followersContent, function(x) 
    {
      df <- data_frame(user = x$login, userID = x$id, followersURL = x$followers_url, followingURL = x$following_url)
    }) %>% bind_rows()
    i <- i+1
    x <- length(followersContent)
    followersDF <- rbind(followersDF, currentFollowersDF)
  }
  return (followersDF)
}




#Get current users list of following
getFollowing <- function(username)
{
  i <- 1
  x <- 1
  followingDF <- data_frame()
  while(x!=0)
  {
    following <- GET( paste0("https://api.github.com/users/", username, "/following?per_page=100&page=", i))
    followingContent <- content(following)
    currentFollowingDF <- lapply(followingContent, function(x) 
    {
      df <- data_frame(user = x$login, userID = x$id, followersURL = x$followers_url, followingURL = x$following_url)
    }) %>% bind_rows()
    i <- i+1
    x <- length(followingContent)
    followingDF <- rbind(followingDF, currentFollowingDF)
  }
  return (followingDF)
}



#Check if we have already saved a users details
checkDuplicate <- function(dataframe)
{
  noDuplicates <- distinct(dataframe)
  return(noDuplicates)
}


allUsers <- data_frame()
addUser <- function(username)
{
  followers <- getFollowers(username)
  following <- getFollowing(username)
  allUsers <- rbind(allUsers,followers,following)
  checkForDups <- checkDuplicate(allUsers)
  return(checkForDups)
}

list <- addUser('phadej')
#Save in CSV form
write.csv(followingDF, file="dataTest.csv")
