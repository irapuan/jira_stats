# GetJiraInformation

require("httr")
require("jsonlite")


config <- config::get(file = "config.yml")

get_stories_by_filter <- function(filter) {
  endpoint <- "search"
  
  get_issues_dataframe <- data.frame()
  
  isTheLastPage <- FALSE
  page <- 0
  maxResults <- 100
  #fields=resolutiondate,created,issuetype&
  while (!isTheLastPage) {
    call1 <- paste(config$base_url,endpoint,"?jql=", filter ,"&expand=changelog&fields=resolutiondate,created,issuetype,changelog&maxResults=", maxResults, "&page=",page, sep ="")
    
    get_issues <- GET(call1, add_headers("Authorization" = config$token))
    
    get_issues <- content(get_issues,"text")
    
    get_issues_json <- fromJSON(get_issues, flatten = TRUE)
    
    get_issues_dataframe <- rbind(get_issues_dataframe,as.data.frame(get_issues_json))
    
    page <- page + maxResults
    total <- strtoi(get_issues_json$total)
    
    if (total <= page) {
      isTheLastPage <- TRUE
    }
    
  }
  
  get_issues_dataframe
  
}