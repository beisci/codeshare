## Make sure the latest distributions of "pandoc" is installed
## If PDF report needed Tex also should be installed
## Also require all following packages, uncomment the following line for installation from CRAN
## install.packages(c("data.table", "ggplot2", "scales", "rmarkdown", "knitr", "kableExtra", "car")))
## Must install REDCapR from gibhub and not from CRAN, to do so:
## install.packages("devtools") # Run this line if the 'devtools' package isn't installed already.
## devtools::install_github(repo="OuhscBbmc/REDCapR")

## Enter information for the source script

library(data.table)
library(ggplot2)
library(scales)
library(rmarkdown)
library(REDCapR)
library(car)
library(knitr)
library(kableExtra)


redcap_api <-fread("~/EXAMPLE_PATH/REDCapAPI.csv")

d <- as.data.table(redcap_read(redcap_uri = "https://redcap.cdms.org.au/api/",
            token = as.character(redcap_api[proj == "healthysleepdiary", .(api)]),
            export_survey_fields = TRUE)$data)

d[, Date := as.Date(sleep_diary_timestamp, format = "%Y-%m-%d")]

## Recode variables that if left NA becomes 0

d.na <- d[, .(solhr, solmin, snoohr, snoomin, tstsmin,
              wasohr, wasomin, emahr, emamin, naphr, napmin)]


va.na <- c("solhr", "solmin", "snoohr", "snoomin", "tstsmin",
              "wasohr", "wasomin", "emahr", "emamin", "naphr", "napmin")

for (i in va.na) {
    d[, (i) := recode(get(i), "NA = 0")]
}


d$BThr <- as.numeric(gsub("(.*):(.*):(.*)$", "\\1", d$bt)) +
  as.numeric(gsub("(.*):(.*):(.*)$", "\\2", d$bt))/60

d$LOhr <- as.numeric(gsub("(.*):(.*):(.*)$", "\\1", d$lo)) +
  as.numeric(gsub("(.*):(.*):(.*)$", "\\2", d$lo))/60

d$WThr <- as.numeric(gsub("(.*):(.*):(.*)$", "\\1", d$wt)) +
  as.numeric(gsub("(.*):(.*):(.*)$", "\\2", d$wt))/60

d$RThr <- as.numeric(gsub("(.*):(.*):(.*)$", "\\1", d$rt)) +
  as.numeric(gsub("(.*):(.*):(.*)$", "\\2", d$rt))/60

d[BThr >15 & BThr <= 24, BThr := BThr - 24]
d[BThr > 6, BThr := BThr + 12 - 24]

d[LOhr >16 & LOhr <= 24, LOhr := LOhr - 24]
d[LOhr > 5.5, LOhr := LOhr + 12 - 24]

# d[LOhr > WThr, c("LOhr", "BThr") := .(NA_real_, NA_real_)]

d[, TIBhr := RThr - BThr]
d[TIBhr < 0, TIBhr := NA_real_]
d[, TSTshr := tstshr + tstsmin/60] #subjective TSThr
#d[, TSThr := TIBhr - SOL/60 - WASOT/60 - SNZ/60 - (RThr - WThr)]
d[, SEs := TSTshr/TIBhr*100]
d[SEs > 100, SEs := 100]

d[, SOL := solhr * 60 + solmin]
d[, WASOT := wasohr * 60 + wasomin]

## Make medication and notes summary

d[, med_summary := paste0(slp_med_1, " ", slp_med_dose_1, " at ", slp_med_time_1, ". ",
                          slp_med_2, " ", slp_med_dose_2, " at ", slp_med_time_2, ". ",
                          slp_med_3, " ", slp_med_dose_3, " at ", slp_med_time_3, ". ",
                          slp_med_4, " ", slp_med_dose_4, " at ", slp_med_time_4, ". ")]

## Remove NA

d$med_summary <- gsub("NA NA at NA. ","", d$med_summary)

med.table.data <- d[med_summary != "", .(record_id, Date, med_summary)]

setnames(med.table.data, "med_summary", "Medication")

note.table.data <- d[!is.na(diary_note), .(record_id, Date, diary_note)]
setnames(note.table.data, "diary_note", "Notes")

## Generate reports for every unique ID

error.ids <- vector("character", 0)

for (i in unique(d$record_id)) {
ID <- i

    res <- tryCatch({
    render("DiaryReport.Rmd", output_format = "html_document",
           output_file = paste0("Diary_", ID, ".html"))

    ## Uncomment the following two lines if PDF is needed
    ## render("Diary Report.Rmd", output_format = "pdf_document",
    ##        output_file = paste0("Diary_", ID, ".pdf"))

    },
      error = function(e) "error")

    if (identical(res, "error")) {
        error.ids <- c(error.ids, i)
    }
}



## if (length(error.ids)) {
##     ## take some action
## }
