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

  ## Get the risk tier
  d$Tier <- substr(d$Advice_title, 1, 6)
  
  ## Make myAdvice
  d[, myAdvice := paste0(Suburb, "(", Tier, "): ", Site_title, ", ", Site_streetaddress, ", ", Exposure_date, ", ", Exposure_time)]
  d[, Added_date := as.Date(parse_date_time(Added_date, orders = c('dmy', 'mdy', 'ymd')))] # in case format changes
  dn[, diagnosis_date := as.Date(parse_date_time(diagnosis_date, orders = c('ymd', 'dmy', 'mdy')))]

  ## Sort by suburb and exposure sites
  setkeyv(d, c("Suburb", "Site_title"))

  print("New cases over the past day in my LGAs:")
  print(table(dn[Localgovernmentarea %in% lga & diagnosis_date >= (Sys.Date() -1)]$Localgovernmentarea))
  
  print("Total new cases over the past day in Victoria:")
  print(dn[diagnosis_date >= (Sys.Date() - 1), .N])
  
  print(paste0("Exposure sites posted in the last ", n, " days:"))
  if(d[Suburb %in% sub & Added_date >= (Sys.Date() - n), .N] == 0) {
    print("None.")
  } else {
    print(d[Suburb %in% sub & Added_date >= (Sys.Date() - n), .(myAdvice)])
  }
  print("All current exposure sites:")
  print(d[Suburb %in% sub, .(myAdvice)])
}

## Personalise suburbs and LGA for the output
mySuburbs <- c("Notting Hill", "Clayton",
               "Bentleigh", "East Bentleigh", "Oakleigh", "Oakleigh South",
               "Brighton", "East Brighton",
               "West Melbourne", "North Melbourne", "Flemington", "Parkville")

myLGA <- c("Glen Eira (C)", "Bayside (C)", "Monash (C)", "Melbourne (C)")

## Get report for past 2 days and all current advice
COVIDexpo(n = 2, sub = mySuburbs, lga = myLGA)
