library(data.table)
library(lubridate)

## Get data
d <- fread("https://drive.google.com/uc?export=download&id=1hULHQeuuMQwndvKy1_ScqObgX0NRUv1A")

## Get the risk tier
d$Tier <- substr(d$Advice_title, 1, 6)
  
## Make myAdvice
d[, myAdvice := paste0(Suburb, "(", Tier, "): ", Site_title, ", ", Site_streetaddress, ", ", Exposure_date, ", ", Exposure_time)]
d[, Added_date := as.Date(parse_date_time(Added_date, orders = c('dmy', 'mdy', 'ymd')))] # in case format changes

## Sort by suburb and exposure sites
setkeyv(d, c("Suburb", "Site_title"))

## Function to get exposure advice for the past n days and all current advice
## For exposure sites added today, n = 0.

COVIDexpo <- function(n){
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
sub <- c("Notting Hill", "Clayton", "Bentleigh", "North Melbourne")

## Get report for past 2 days and all current advice
COVIDexpo(2)
