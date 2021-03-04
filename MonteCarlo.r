library(dplyr)
library(ggplot2)
library(tidyr)
library(lubridate)
source("JiraAPIWrapper/JiraAPI.R")

filter <- "labels in (MX9-GA) AND resolution is not empty AND project = AA"

get_issues_dataframe <- get_stories_by_filter(filter)

sample_x <- function(Total, Historico) {
  n <- 0
  i <- Total
  while(i >=0) {
    n <- n + 1
    i <- i - sample(Historico, size = 1)
  }
  n
}

jira_data <- get_issues_dataframe %>%
  mutate(created = as.Date(issues.fields.created, "%Y-%m-%dT%H:%M:%OS"),
         closed = as.Date(issues.fields.resolutiondate, "%Y-%m-%dT%H:%M:%OS"),
         cycletime = as.numeric(difftime(closed, created), units="days"),
         issuetype = issues.fields.issuetype.name)


throughput <- jira_data %>%
  mutate(week = strftime(closed, "%Y-%V")) %>%
  select(week) %>%
  group_by(week) %>%
  count()


walks <- replicate(1000, sample_x(Total = 100, Historico = throughput$freq))
previsoes <- data.frame(Week  = as.POSIXct(now() + weeks(walks) ),
               Value = walks
)


p95 <- quantile(previsoes$Value, 0.95)
p80 <- quantile(previsoes$Value, 0.80)
p70 <- quantile(previsoes$Value, 0.70)


ggplot(previsoes, aes(x=Value)) +
  geom_histogram(binwidth = 1, aes(y=..density..), colour="black", fill="white") +
  geom_density(alpha=.2, fill="#FF6666") +
  geom_vline(xintercept=p95, linetype="dashed", color = "red")+
  annotate("text", x = p95, y = Inf,  color = "red" , label = "95th Percentile", vjust = "inward") +
  geom_vline(xintercept=p80, linetype="dashed", color = "blue")+
  annotate("text", x = p80, y = Inf,  color = "blue" , label = "80th Percentile", vjust = "inward") +
  geom_vline(xintercept=p70, linetype="dashed", color = "green") +
  annotate("text", x = p70, y = Inf,  color = "green" , label = "70th Percentile", vjust = "inward") 


