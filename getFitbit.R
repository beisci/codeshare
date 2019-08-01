## Do the following before using code:
## 1. Register developer account with Fitbit: https://dev.fitbit.com
## 2. Read Fitbit API documentation https://dev.fitbit.com/build/reference/web-api/
## 3. Register an app via Fitbit developer account. Can use most functional website as the call back site.
## 4. Decide which authorization flow to use. Implicit Grant Flow allows up to 1 year.
## 5. Once app is set up, click on OAuth 2.0 tutorial page and follow each step of the page.
## 6. If using 1 year authorization via Implicit Grant Flow, make sure change the time frame to 31536000, other numbers will defalt to 1 day.
## 7. Ask each user to click on the link and authorise, then obtain API token.
## 8. Store API tokens securely. Example below stores API token securely elsewhere and reads it in.

library(data.table)
library(curl)
library(httr)
library(rjson)

## Read in API tokens. Currently I store this under 3 variables:
## ID, FitbitAPI, Expires

API <- fread("~/example/API.csv")

## Code below checks status of token, look at "Status", can check error code on Fitbit API documentation
## check_state <- function(token = NULL) {
##   POST(url = 'https://api.fitbit.com/1.1/oauth2/introspect',
##        add_headers(Authorization = paste0('Bearer ', token)),
##        body = paste0('token=', token),
##        content_type('application/x-www-form-urlencoded'))
## }
## check_state(token = FitbitAPI)

## Below function gets just the sleep data between StartDate and EndDate.
## Check Fitbit API documentation if all available sleep data, or if other data
## (e.g., activity, diet etc) are to be retrieved. Modify url format accordingly.

get_sleep <- function(StartDate, EndDate, token) {
    x <- GET(url =
             paste0("https://api.fitbit.com/1.2/user/-/sleep/date/",
                    StartDate, "/", EndDate, ".json"),
             add_headers(Authorization = paste0("Bearer ", token)))
    content(x)$sleep
}

## Code below binds dateOfsleep, timeInBed, and minutesAsleep for each date,
## then loop through each ID's token, eventually binds everything into a
## long dataset. Below is for extracting past 30 days from Sys.Date()

fitbit <- do.call(rbind,

                  lapply(API$FitbitAPI, function(y){
                      sleep <- get_sleep(StartDate = (Sys.Date() - 30),
                                         EndDate = Sys.Date(),
                                         token = y)

                      temp <- do.call(rbind,
                                      lapply(sleep, function(x){
                                          data.table(
      date = x$dateOfSleep,
      TIB = x$timeInBed,
      TST = x$minutesAsleep)
}))

    temp[, FitbitAPI := y]
    return(copy(temp))
}))

## Calculate Sleep Efficiency.
fitbit[, SE := round((TST/TIB)*100, digits = 0)]
fitbit <- merge(fitbit, API, by = "FitbitAPI", all.x = TRUE)

## Remove FitbitAPI from final data
fitbit[, FitbitAPI := NULL]
