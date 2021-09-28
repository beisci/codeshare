library(data.table)
library(lubridate)

## Function to get COVID advice for the past n days and all current advice
## For exposure sites added today, n = 0.
## To integrate as an Alfred (https://www.alfredapp.com) workflow,
## add an action after keyword to call the script using "Terminal Command": Rscript PATH/TO/SCRIPT/COVIDexpo.R
## Then activate via Alfred

COVIDexpo <- function(n, sub, lga) {
  ## Get exposure data
  d <- fread("https://drive.google.com/uc?export=download&id=1hULHQeuuMQwndvKy1_ScqObgX0NRUv1A")
  ## Source: https://discover.data.vic.gov.au/dataset/all-victorian-sars-cov-2-covid-19-current-exposure-sites/resource/afb52611-6061-4a2b-9110-74c920bede77

  ## Get case number
  dn <- fread("https://www.dhhs.vic.gov.au/ncov-covid-cases-by-lga-source-csv")
  ## Source: https://www.coronavirus.vic.gov.au/victorian-coronavirus-covid-19-data

  ## Get active case numbers
  da <- fread("https://docs.google.com/spreadsheets/d/e/2PACX-1vQ9oKYNQhJ6v85dQ9qsybfMfc-eaJ9oKVDZKx-VGUr6szNoTbvsLTzpEaJ3oW_LZTklZbz70hDBUt-d/pub?gid=0&single=true&output=csv")
  ## Source: https://www.coronavirus.vic.gov.au/victorian-coronavirus-covid-19-data

  ## Get the risk tier
  d$Tier <- substr(d$Advice_title, 1, 6)
  
  ## Make myAdvice
  d[, myAdvice := paste0(Suburb, "(", Tier, "): ", Site_title, ", ", Site_streetaddress, ", ", Exposure_date, ", ", Exposure_time)]
  d[, Added_date := as.Date(parse_date_time(Added_date, orders = c('dmy', 'mdy', 'ymd')))] # in case format changes
  dn[, diagnosis_date := as.Date(parse_date_time(diagnosis_date, orders = c('ymd', 'dmy', 'mdy')))]

  ## Rename and sort
  setnames(dn, c("Localgovernmentarea", "diagnosis_date"), c("LGA", "Diagnosed"))

  setkeyv(d, c("Suburb", "Site_title"))
  setkeyv(dn, c("LGA", "Postcode", "Diagnosed"))

  cat("Current total new daily cases in Victoria:", "\n")
  cat(dn[Diagnosed >= (Sys.Date() - 1), .N], "\n\n")

  cat("Total new cases from the previous day in Victoria:", "\n")
  cat(dn[Diagnosed == (Sys.Date() - 2), .N], "\n")

  cat("\nNew cases over the past day in my LGAs:")
  print(table(dn[LGA %in% lga & Diagnosed >= (Sys.Date() -1)]$LGA), row.names = FALSE)

  cat("\nActive and total cases in my LGAs:", "\n")
  print(da[LGA %in% lga, .(LGA, active, cases)], row.names = FALSE)

  ## cat(paste0("\nRelevant exposure sites posted in the last ", n, " days:\n"))
  ## if(d[Suburb %in% sub & Added_date >= (Sys.Date() - n), .N] == 0) {
  ##   cat("None.", "\n")
  ## } else {
  ##   print(table(d[Suburb %in% sub & Added_date >= (Sys.Date() - n)]$myAdvice),
  ##         row.names = FALSE, col.names = FALSE)
  ## }

  cat("\nAll current exposure sites:\n")
  cat(d[Suburb %in% sub]$myAdvice, sep = "\n")

  cat(paste0("\nNew cases in my LGAs over the last ", n, " days:"))
  print(dn[LGA %in% lga & Diagnosed >= (Sys.Date() - n),
           .(Diagnosed, LGA, Postcode, acquired)])
}

## Personalise suburbs and LGA for the output
mySuburbs <- c("Notting Hill", "Clayton",
               "Bentleigh", "East Bentleigh", "Oakleigh", "Oakleigh South",
               "Brighton", "East Brighton",
               "West Melbourne", "North Melbourne", "Flemington", "Parkville")

myLGA <- c("Glen Eira (C)", "Bayside (C)", "Monash (C)", "Melbourne (C)")

## Get report for past 3 days and all current advice
COVIDexpo(n = 3, sub = mySuburbs, lga = myLGA)
