# CS3012Assignment5
Interrogate the GitHub API to retrieve and display data regarding the logged in developer.

I have completed this assignment using R. 

The steps in this development process involved:
  1. Registering for an OAuth application to Github and recieving a Github access token.
  2. Setting up my token credentials in an R script to ensure unlimited access to Github data.
  3. Using the GET() function from the httr() package to retrieve users data from Github - followers, repos, languages etc.
  4. Processing the data I recieved - storing it in a dataframe, removing duplicates, sorting etc. 
  5. Downloading the plotly() package, setting up a plotly account online and using their interactive graphing functions to        visualise the user data. 

For this assignment I decided to look at the relationship between the number of followers and number of repositories a Github user has. I expected there to be some form of a positive linear relationship - expecting those who were more active in terms of repositories to have more followers. This was not the case. 
I also created a function which shows the repository languages implemented by a given user. I thought this was useful, and interesting data to have access to.


Link to my plotly account with visualization: https://plot.ly/~aoifetiernan

Graph 1: https://plot.ly/~aoifetiernan/8
Graph 2: https://plot.ly/~aoifetiernan/10
Graph 3: https://plot.ly/~aoifetiernan/12

Note: I have put screenshots of my visualization in this repo but the above link will display my plotly homepage.


