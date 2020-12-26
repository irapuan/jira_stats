# GetJiraInformation

require("httr")
require("jsonlite")


config <- config::get(file = "config.yml")

escape_characters <- function(filter) {
  str_replace_all(filter, " ","+")
}

get_stories_by_filter <- function(filter) {
  endpoint <- "search"
  
  filter <- escape_characters(filter)
  
  get_issues_dataframe <- data.frame()
  
  isTheLastPage <- FALSE
  page <- 0
  maxResults <- 100
  while (!isTheLastPage) {
    http_request <- paste(config$base_url,endpoint,"?jql=", filter ,"&fields=resolutiondate,created,issuetype&maxResults=", maxResults, "&startAt=",page, sep ="")
    
    get_issues <- GET(http_request, add_headers("Authorization" = config$token))
    
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


