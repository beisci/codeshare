library(data.table)
library(lubridate)

## Function to get exposure advice for the past n days and all current advice
## For exposure sites added today, n = 0.

COVIDexpo <- function(n, sub){
  ## Get data
  d <- fread("https://drive.google.com/uc?export=download&id=1hULHQeuuMQwndvKy1_ScqObgX0NRUv1A")
  ## Source: https://discover.data.vic.gov.au/dataset/all-victorian-sars-cov-2-covid-19-current-exposure-sites/resource/afb52611-6061-4a2b-9110-74c920bede77

  ## Get the risk tier
  d$Tier <- substr(d$Advice_title, 1, 6)
  
  ## Make myAdvice
  d[, myAdvice := paste0(Suburb, "(", Tier, "): ", Site_title, ", ", Site_streetaddress, ", ", Exposure_date, ", ", Exposure_time)]
  d[, Added_date := as.Date(parse_date_time(Added_date, orders = c('dmy', 'mdy', 'ymd')))] # in case format changes

  ## Sort by suburb and exposure sites
  setkeyv(d, c("Suburb", "Site_title"))

  print(paste0("Exposure sites posted in the last ", n, " days:"))
  if(d[Suburb %in% sub & Added_date >= (Sys.Date() - n), .N] == 0) {
    print("None.")
  } else {
    print(d[Suburb %in% sub & Added_date >= (Sys.Date() - n), .(myAdvice)])
  }
  print("All current exposure sites:")
  print(d[Suburb %in% sub, .(myAdvice)])
}

## Personalise suburbs for the output
mySuburbs <- c("Notting Hill", "Clayton", "Bentleigh", "West Melbourne")

## Get report for past 2 days and all current advice
COVIDexpo(n = 2, sub = mySuburbs)
