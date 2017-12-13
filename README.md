# CS3012Assignment5
Interrogate the GitHub API to retrieve and display data regarding the logged in developer.

I have completed this assignment using R. 

The steps in this development process involved:
  1. Registering for an OAuth application to Github and recieving a Github access token.
  2. Setting up my token credentials in an R script to ensure unlimited access to Github data.
  3. Using the GET() function from the httr() package to retrieve users data from Github - followers, repos, languages etc.
  4. Processing the data I recieved - storing it in a dataframe, removing duplicates, sorting etc. 
  5. Downloading the plotly() package, setting up a plotly account online and using their interactive graphing functions to        visualise the user data. 

Link to my visualization: https://plot.ly/~aoifetiernan/6
Note: I have put a screenshot off my visualization in this repo but the above link will display the interactive plot I have created. 



