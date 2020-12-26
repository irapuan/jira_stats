library(dplyr)
library(ggplot2)
library(tidyr)
library(tidyverse)
library(lubridate)


source("JiraAPI.R")


get_issues_dataframe <- get_stories_by_filter("project=SPVC+and+created>startOfMonth(-3)")

jira_data <- get_issues_dataframe %>%
  mutate(created = as.Date(issues.fields.created, "%Y-%m-%dT%H:%M:%OS"),
         closed = as.Date(issues.fields.resolutiondate, "%Y-%m-%dT%H:%M:%OS"),
         cycletime = as.numeric(difftime(closed, created), units="days") + 1,
         issuetype = issues.fields.issuetype.name) %>%
  filter(!is.na(closed)) 


jira_selected <- jira_data %>%
  select(issuetype,created, closed, cycletime)


final_data <- jira_selected %>%
  group_by(date = format(closed,"%Y-%U"), issuetype) %>% 
  count() %>%
  mutate(throughput = n)

avg <- mean(final_data$throughput)


ggplot(final_data, aes(x=date, y=throughput)) + 
  geom_col(aes(fill=issuetype)) +
  geom_hline(yintercept=avg, linetype="dashed", color = "red")+
  annotate("text", x = Inf, y = avg, color = "red" , label = "Mean", vjust = -0.5, hjust = "inward") 
