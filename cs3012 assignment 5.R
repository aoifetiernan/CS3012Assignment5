#Author: Aoife Tiernan
#Last updated: 13/12/2017

#install the necessary packages
library(httpuv)
library(httr)
detach(package:plotly, unload=TRUE)

#Select github as the endpoint
oauth_endpoints("github")


#Enter the details for my personal github application
myApplication <- oauth_app(appname = "AoifeTiernanCS3012",
                   key = "b48eac03318fa39aa787",
                   secret = "")


#Set and get my github token 
githubToken <- oauth2.0_token(oauth_endpoints("github"), myApplication)
getToken <- config(token = githubToken)



#Returns a dataframe with information on the Current Users Followers 
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





#Returns a dataframe with information on the Current Users Repositories
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
      df <- data_frame(repo = x$name, id = x$id, commits = x$git_commits_url, language = x$languages) #language = x$language)
    }) %>% bind_rows()
    i <- i+1
    x <- length(reposContent)
    reposDF <- rbind(reposDF, currentReposDF)
  }
  return (reposDF)
}





#Returns a dataframe with the language used in each of the users repos
getLanguages <- function(username)
{
  
  reposDF <- GET( paste0("https://api.github.com/users/", username, "/repos?per_page=100"),getToken)
  repoContent <- content(reposDF)
  i <- 1
  languageDF <- data_frame()
  numberOfRepos <- length(repoContent)
  for(i in 1:numberOfRepos)
  {
    repoLanguage <- repoContent[[i]]$language
    repoName <- repoContent[[i]]$name
    if(is_null(repoLanguage))
    {
      currentLanguageDF <- data_frame(repo = repoName, language = "No language specified")
    }else
    {
      currentLanguageDF <- data_frame(repo = repoName, language = repoLanguage)
    }
    i <- i+1
    languageDF <- rbind(languageDF, currentLanguageDF)
  }
  return (languageDF)
}



#Returns a pie chart which depicts the languages information for the current user
languagesVisualization <- function(username)
{
  z <- getLanguages(username)
  x <- data.frame(table(z$language))
  
  pie <- plot_ly(data =x, labels = ~Var1, values = ~Freq, type = 'pie') %>%
    layout(title = paste('Languages used by Github User', username),
           xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
           yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
  return(pie)
  
}





#Returns a dataframe giving the number of followers and number of repos a user has
getFollowersInformation <- function(username)
{
  
  followersDF <- getFollowers(username)
  numberOfFollowers <- length(followersDF$userID)
  followersUsernames <- followersDF$user
  data <- data.frame()
  #Iterating through the current users followers to extract number of followers 
  #and number of repos
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
  return(data)
}



#Checks for duplicate observations in a dataframe
checkDuplicate <- function(dataframe)
{
  noDuplicates <- distinct(dataframe)
  return(noDuplicates)
}



#Generate data for followers and repos starting at user phadej
currentUser <- "phadej"
x <- getFollowers(currentUser)
followersUsernames <- x$user
numberOfFollowers <- length(x$userID)
fullData <- getFollowersInformation(currentUser)
i <- 1
while(nrow(fullData)<15000)
{
  current <- followersUsernames[i]
  newData <- getFollowersInformation(current)
  fullData <- rbind(newData, fullData)
  i <- i+1
}
fullData <- checkDuplicate(fullData)
#originally - 1500 With duplicates taken out - 1363





#Use plotly to graph the relationship between a users number of followers and repositories 
library(plotly)
scatter <- plot_ly(data = fullData, x = ~numberOfFollowers, y = ~numberOfRepositories,
             text = ~paste("User: ", userName, '<br>Followers: ', numberOfFollowers, '<br>Repos:', numberOfRepositories),
             marker = list(size = 10, color = 'rgba(255, 182, 193, .9)',
             line = list(color = 'rgba(152, 0, 0, .8)',width = 2))) %>%
            layout(title = 'Relationship between Followers and Repositories',yaxis = list(zeroline = FALSE),xaxis = list(zeroline = FALSE),
            plot_bgcolor='rgba(63, 191, 165,0.2)')
scatter




#Extracting data for users with over 1000 followers or repositories
mostFollowers <- fullData[which(fullData$numberOfFollowers>=1000),]
mostFollowers$code = 1
mostRepos <- fullData[which(fullData$numberOfRepositories>=1000),]
mostRepos$code = 0

combined <- rbind(mostFollowers,mostRepos)
scatter2 <- plot_ly(data = combined, x = ~numberOfFollowers, y = ~numberOfRepositories, color = ~code, colors = "Set1",
             text = ~paste("User: ", userName, '<br>Followers: ', numberOfFollowers, '<br>Repos:', numberOfRepositories)) %>%
  layout(title = 'Most Followers and Repositories',yaxis = list(zeroline = FALSE),xaxis = list(zeroline = FALSE),
         plot_bgcolor='rgba(63, 191, 165,0.2)')
scatter2




#language Information For Phadej
pie <- languagesVisualization("MichalPaszkiewicz")
pie



#Upload my plots to the plotly website
Sys.setenv("plotly_username"="aoifetiernan")
Sys.setenv("plotly_api_key"="38EZqWM1Q4XdRGAL5p7J")
api_create(scatter, filename = "Followers and Repository Relationship")
api_create(scatter2, filename="Users with the most Followers and Repositories")
api_create(pie, filename="Languages visualization")

#Save in CSV form
write.csv(fullData, file="followerRepoData.csv")
