## Examples of reading in data from REDCap
## Need to install REDCapR from github, which will allow survey timestamp
## to be download: 
## install.packages("devtools") # Run this line if the 'devtools' package isn't installed already.
## devtools::install_github(repo="OuhscBbmc/REDCapR")

library(data.table)
library(REDCapR)

## Store and read in API tokens from a secure location
## I have two variables for the file I use:
## proj: name of the project,
## api: corresponding API token
## This is helpful for accessing multiple projects

redcap_api <-fread("~/location/REDCapAPI.csv")

## Uncomment below to retrieve specific records or varibles
## return_records <- c(1, 4)
## return_fields <- c("id", "name", "age")

d <- as.data.table(redcap_read(redcap_uri = "https://redcap.cdms.org.au/api/",
                               token = as.character(redcap_api[proj == "ProjectName", .(api)]),
                               export_survey_fields = TRUE # needed to be TRUE for timestamp to be retrieved
                               ## fields = return_fields,
                               ## records = return_records
                               )$data)
