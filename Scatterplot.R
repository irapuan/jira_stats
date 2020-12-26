library(dplyr)
library(ggplot2)
library(tidyr)

source("JiraAPIWrapper/JiraAPI.R")


filter <- "project=MS and created > startOfMonth(-3) and issuetype in (Bug,Story)"

get_issues_dataframe <- get_stories_by_filter(filter)

jira_data <- get_issues_dataframe %>%
  mutate(created = as.Date(issues.fields.created, "%Y-%m-%dT%H:%M:%OS"),
         closed = as.Date(issues.fields.resolutiondate, "%Y-%m-%dT%H:%M:%OS"),
         cycletime = as.numeric(difftime(closed, created), units="days"),
         issuetype = issues.fields.issuetype.name) %>%
  filter(!is.na(closed))

jira_selected <- jira_data %>%
  select(issues.key,created, closed, cycletime)

p95 <- quantile(jira_data$cycletime, 0.95)
p80 <- quantile(jira_data$cycletime, 0.80)
p70 <- quantile(jira_data$cycletime, 0.70)


ggplot(jira_data, aes(x=closed, y=cycletime)) + 
  geom_point(aes(col=issuetype))+
  geom_hline(yintercept=p95, linetype="dashed", color = "red")+
  annotate("text", x = min (jira_data$closed), y = p95, color = "red" , label = "95th Percentile", vjust = -0.5, hjust = "inward") +
  geom_hline(yintercept=p80, linetype="dashed", color = "blue")+
  annotate("text", x = min (jira_data$closed), y = p80 , color = "blue", label = "80th Percentile", vjust = -0.5, hjust = "inward") +
  geom_hline(yintercept=p70, linetype="dashed", color = "green") +
  annotate("text", x = min (jira_data$closed), y = p70 , color = "green", label = "70th Percentile", vjust = -0.5, hjust = "inward") 


