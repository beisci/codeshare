## Examples of reading in data from REDCap
## Need to install REDCapR from github, which will allow survey timestamp
## to be download:
## install.packages("devtools") # Run this line if the 'devtools' package isn't installed already.
## devtools::install_github(repo="OuhscBbmc/REDCapR")

## Use keyring to manage API security

library(data.table)
library(REDCapR)
library(keyring)

## Create API in macOS keychain
## key_set("ProjectName", "Username")
## Enter API as password when prompted

redcap_api <- key_get("ProjectName")

## Uncomment below to retrieve specific records or varibles
## return_records <- c(1, 4)
## return_fields <- c("id", "name", "age")

d <- as.data.table(redcap_read(redcap_uri = "https://redcap.cdms.org.au/api/",
                               token = redcap_api,
                               export_survey_fields = TRUE # needed to be TRUE for timestamp to be retrieved
                               ## fields = return_fields,
                               ## records = return_records
                               )$data)
