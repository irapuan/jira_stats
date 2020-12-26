# R Jira Stats

Simple R scripts to generate some insigths on Jira boards.

## how to use

1 - Create a file called config.yml that looks like to this one: 

```{yml}
default:
  token: <<Token to access Jira>>
  base_url: https://<<your jira instance address>>.atlassian.net/rest/api/2/

```

[Getting Jira API token](https://confluence.atlassian.com/cloud/api-tokens-938839638.html)

2 - Change the variable filter at the beginning of each script using [JQL language](https://www.atlassian.com/software/jira/guides/expand-jira/jql) and run the scripts in RStudio.

![Scatter Plot](img/scatterplot.jpg)
![Histogram](img/histogram.jpg)
![Throughput](img/throughput.jpg)


## Installing dependencies

```{R}
install.packages(dplyr)
install.packages(ggplot2)
install.packages(tidyr)
install.packages(tidyverse)
install.packages(lubridate)
install.packages(httr)
install.packages(jsonlite)

```

## To do
- [ ] Refactor the scripts to not duplicate code.
