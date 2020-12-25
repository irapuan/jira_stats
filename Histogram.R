library(dplyr)
library(ggplot2)
library(tidyr)

source("JiraAPI.R")


config <- config::get(file = "config.yml")


get_issues_dataframe <- get_stories_by_filter("project=MS")

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


ggplot(jira_data, aes(x=cycletime, fill=issuetype)) +
  geom_histogram(binwidth = 1)+
  geom_vline(xintercept=p95, linetype="dashed", color = "red")+
  annotate("text", x = p95, y = Inf,  color = "red" , label = "95th Percentile", vjust = "inward") +
  geom_vline(xintercept=p80, linetype="dashed", color = "blue")+
  annotate("text", x = p80, y = Inf,  color = "blue" , label = "80th Percentile", vjust = "inward") +
  geom_vline(xintercept=p70, linetype="dashed", color = "green") +
  annotate("text", x = p70, y = Inf,  color = "green" , label = "70th Percentile", vjust = "inward") 



