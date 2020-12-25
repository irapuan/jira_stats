library(dplyr)
library(ggplot2)
library(tidyr)

require("httr")
require("jsonlite")

config <- config::get(file = "config.yml")

endpoint <- "search"

get_issues_dataframe <- data.frame()

isTheLastPage <- FALSE
page <- 0
maxResults <- 100
#fields=resolutiondate,created,issuetype&
while (!isTheLastPage) {
  call1 <- paste(config$base_url,endpoint,"?jql=project=MS&expand=changelog&fields=resolutiondate,created,issuetype,changelog&maxResults=", maxResults, "&page=",page, sep ="")
  
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


jira_data <- get_issues_dataframe %>%
  mutate(created = as.Date(issues.fields.created, "%Y-%m-%dT%H:%M:%OS"),
         closed = as.Date(issues.fields.resolutiondate, "%Y-%m-%dT%H:%M:%OS"),
         cycletime = as.numeric(difftime(closed, created), units="days"),
         issuetype = issues.fields.issuetype.name) %>%
  unnest(issues.changelog.histories, names_sep = "_hist_") %>%
  unnest(issues.changelog.histories_hist_items, names_sep = "_item_") %>%
  filter(issues.changelog.histories_hist_items_item_field == "status") %>%
  mutate(status = issues.changelog.histories_hist_items_item_toString,
         status_date = as.Date(issues.changelog.histories_hist_created, "%Y-%m-%dT%H:%M:%OS"))

jira_selected <- jira_data %>%
  select(issues.key,created, closed, cycletime, status, status_date)


status_dt <- jira_selected %>%
  select(issues.key, status, status_date)

create_dt <- jira_selected %>%
  select(issues.key,created, closed) %>%
  gather(status, status_date, created:closed)


combined <- rbind(status_dt, create_dt)


combined_sort <- combined %>%
  arrange(issues.key)


jira_count <- combined_sort %>% 
  count(status_date, status)

jira_cum <- jira_count %>% 
  filter(!is.na(status_date)) %>%
  filter(!is.na(status)) %>%
  group_by(status) %>%
  mutate(cum_sep_len = cumsum(n))

a <- jira_cum %>%
  complete(status_date = seq.Date(min(status_date), max(status_date), by="day"),status) %>%
  group_by(status) %>%
  fill(cum_sep_len, .direction = "downup") %>%
  replace_na(list(cum_sep_len=0)) %>%
  mutate(status = factor(status, levels=c("created","Options","Blocked", "PO Review", "Architectural Design","Needs Refinement", "Ready to Start","Backlog" ,"To Do","Design","In Progress","Review","Test Automation","In Test","Done","closed")))


ggplot(a, aes(x=status_date, y=cum_sep_len, fill=status)) + 
  geom_area()

plot(jira_cum$status_date, jira_cum$cum_sep_len)

jira_spread <- jira_selected %>%
  spread(status, status_date)

hist(jira_data$cycletime)

p95 <- quantile(jira_data$cycletime, 0.95)
p80 <- quantile(jira_data$cycletime, 0.80)
p70 <- quantile(jira_data$cycletime, 0.70)

ggplot(jira_data, aes(x=closed, y=cycletime)) + 
  geom_point(aes(col=issuetype))+
  geom_hline(yintercept=p95, linetype="dashed", color = "red")+
  geom_hline(yintercept=p80, linetype="dashed", color = "blue")+
  geom_hline(yintercept=p70, linetype="dashed", color = "green")


ggplot(jira_data, aes(x=cycletime, fill=issuetype)) +
  geom_histogram(binwidth = 1)+
  geom_vline(xintercept=p95, linetype="dashed", color = "red")+
  geom_vline(xintercept=p80, linetype="dashed", color = "blue")+
  geom_vline(xintercept=p70, linetype="dashed", color = "green")



