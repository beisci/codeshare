## Examples of reading in data from REDCap

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
## desired_fields <- c("id", "name", "age")

d <- as.data.table(redcap_read(redcap_uri = "https://redcap.cdms.org.au/api/",
                               token = redcap_api[proj == "ProjectName", .(api)],
                               ## fields = return_fields,
                               ## records = return_records
                               )$data)
