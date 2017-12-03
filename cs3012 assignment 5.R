#Author: Aoife Tiernan
#Last updated: 21/11/2017

#install the necessary packages
library(jsonlite)
library(httpuv)
library(httr)
library(dplyr)
library(tidyverse)
library(ggplot2)

#Select github as the endpoint
oauth_endpoints("github")


#Enter the details for my personal github application
myapp <- oauth_app(appname = "AoifeTiernanCS3012",
                   key = "b48eac03318fa39aa787",
                   secret = "b38c1c62e04b79152a3514bbac4b4a7fd1f6cde7")


#Set and get my github token 
githubToken <- oauth2.0_token(oauth_endpoints("github"), myapp)
getToken <- config(token = githubToken)



#Returns the Information on the Current Users Followers 
getFollowers <- function(username)
{
  i <- 1
  x <- 1
  followersDF <- data_frame()
  while(x!=0)
  {
    followers <- GET( paste0("https://api.github.com/users/", username, "/followers?per_page=100&page=", i),getToken)
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



#Returns the Information on the Current Users Repositories
getRepos <- function(username)
{
  i <- 1
  x <- 1
  reposDF <- data_frame()
  while(x!=0)
  {
    repos <- GET( paste0("https://api.github.com/users/", username, "/repos?per_page=100&page=", i),getToken)
    reposContent <- content(repos)
    currentReposDF <- lapply(reposContent, function(x) 
    {
      df <- data_frame(repo = x$name, id = x$id, commits = x$git_commits_url) #language = x$language)
    }) %>% bind_rows()
    i <- i+1
    x <- length(reposContent)
    reposDF <- rbind(reposDF, currentReposDF)
  }
  return (reposDF)
}


#Passing in the information of our initial user
followersDF <- getFollowers("phadej")
numberOfFollowers <- length(followersDF$userID)
followersUsernames <- followersDF$user
data <- data.frame()


#Iterating through the current users followers to extract number of followers and number of repos
for(i in 1:numberOfFollowers)
{
  userName <- followersUsernames[i]
  repos <- getRepos(userName)
  followers <- getFollowers(userName) 
  numberOfRepositories <- length(repos$repo)
  numberOfFollowers <- length(followers$user)
  newRow <- data.frame(userName, numberOfRepositories, numberOfFollowers)
  data <- rbind(data, newRow)
  i <- i+1;
}













#Returns the information on the users followed by the parameterized user
getFollowing <- function(username)
{
  i <- 1
  x <- 1
  followingDF <- data_frame()
  while(x!=0)
  {
    following <- GET( paste0("https://api.github.com/users/", username, "/following?per_page=100&page=", i),getToken)
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


#allUsers <- data_frame()
addUser <- function(username)
{
  allUsers <- data_frame()
  followers <- getFollowers(username)
  following <- getFollowing(username)
  allUsers <- rbind(allUsers,followers,following)
  checkForDups <- checkDuplicate(allUsers)
  return(checkForDups)
}


#Save in CSV form
write.csv(followingDF, file="dataTest.csv")
