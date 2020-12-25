library(dplyr)
library(ggplot2)
library(tidyr)
library(tidyverse)
library(lubridate)

source("JiraAPI.R")


get_issues_dataframe <- get_stories_by_filter("project=SPVC")

jira_data <- get_issues_dataframe %>%
  mutate(created = as.Date(issues.fields.created, "%Y-%m-%dT%H:%M:%OS"),
         closed = as.Date(issues.fields.resolutiondate, "%Y-%m-%dT%H:%M:%OS"),
         cycletime = as.numeric(difftime(closed, created), units="days"),
         issuetype = issues.fields.issuetype.name) %>%
  filter(!is.na(closed)) %>%


jira_selected <- jira_data %>%
  select(issuetype,created, closed, cycletime)


final_data <- jira_selected %>%
  group_by(date = format(closed,"%Y-%U"), issuetype) %>% 
  count()


ggplot(final_data, aes(x=date, y=n)) + 
  geom_col(aes(fill=issuetype))

