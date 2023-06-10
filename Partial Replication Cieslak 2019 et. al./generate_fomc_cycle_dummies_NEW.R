install.packages('readxl')
library(readxl)
library(lubridate)

# FOMC cycle week definitions
fomc_w0 <- c(-1:3)
fomc_w1 <- c(4:8)
fomc_w2 <- c(9:13)
fomc_w3 <- c(14:18)
fomc_w4 <- c(19:23)
fomc_w5 <- c(24:28)
fomc_w6 <- c(29:33)





# Helper Functions
get_floor_difftime_days <- function(startdate, date) {
  difftime_days <- as.numeric(floor(difftime(date, startdate, units = "days")))
  return(difftime_days)
}


get_floor_difftime_weeks <- function(startdate, date) {
  difftime_weeks <- as.numeric(floor(difftime(date, startdate, units = "weeks")))
  return(difftime_weeks)
}


get_day_in_fomc_cycle <- function(fomc_cycle_start_date, date) {
  difftime_days <- get_floor_difftime_days(fomc_cycle_start_date, date)
  
  # maybe move the date one day forward bc. first date is on tuesday, most FOMC meetings seem to be on Tuesday...
  # https://www.timeanddate.com/date/weekday.html
  
  
  # lubridate solution:
  # ymd(date) - days(1)

  difftime_weeks <- get_floor_difftime_weeks(fomc_cycle_start_date, date)
  
  # use wday instead...
  if ((difftime_days + 1) %% 7 == 5) {
    return(NULL) # Sat. -> not in FOMC cycle
  } 
  
  if ((difftime_days + 1) %% 7 == 6) {
    return(NULL) # Sun. -> not in FOMC cycle
  }
  
  subtract_amount <- 0
  if (difftime_days >= 6){
    
    subtract_amount <- (difftime_weeks) * 2
    if (subtract_amount == 0) subtract_amount <- 2
  }
  
  fomc_day_rank <- difftime_days - subtract_amount

  return(fomc_day_rank)
}



fomc_test_date <- as.Date("2014-01-28")


wday(fomc_test_date, week_start = 1) # 2 = Tuesday

wday(as.Date("2014-02-03"), week_start = 1) - 2 + 5 # => -1 = Tuesday + 5 for each FOMC week
wday(as.Date("2014-02-04"), week_start = 1) - 2  + 5 # => 0 = Tuesday + 5 for each FOMC week


get_day_in_fomc_cycle(fomc_test_date, as.Date("2014-01-24")) # Fri: -2 

# desired return values:
# NULL NULL -1 0 1 2 3 NULL NULL 4 5
get_day_in_fomc_cycle(fomc_test_date, as.Date("2014-01-25")) # NULL
get_day_in_fomc_cycle(fomc_test_date, as.Date("2014-01-26")) # NULL
get_day_in_fomc_cycle(fomc_test_date, as.Date("2014-01-27")) # Mo: -1 -> fomc_w0
get_day_in_fomc_cycle(fomc_test_date, as.Date("2014-01-28")) # Tue: 0 -> fomc_w0
get_day_in_fomc_cycle(fomc_test_date, as.Date("2014-01-29")) # Wed: 1 -> fomc_w0
get_day_in_fomc_cycle(fomc_test_date, as.Date("2014-01-30")) # Thu: 2 -> fomc_w0
get_day_in_fomc_cycle(fomc_test_date, as.Date("2014-01-31")) # Fri: 3 -> fomc_w0
get_day_in_fomc_cycle(fomc_test_date, as.Date("2014-02-01")) # Sat: 4 -> NULL
get_day_in_fomc_cycle(fomc_test_date, as.Date("2014-02-02")) # Sun: 5 -> NULL
get_day_in_fomc_cycle(fomc_test_date, as.Date("2014-02-03")) # Mo:  6 - 2 = 4 -> fomc_w1
get_day_in_fomc_cycle(fomc_test_date, as.Date("2014-02-04")) # Tue: 7 - 2 = 5 -> fomc_w1

get_day_in_fomc_cycle(fomc_test_date, as.Date("2014-02-05")) # Wed: 8 - 2 = 6 -> fomc_w1
get_day_in_fomc_cycle(fomc_test_date, as.Date("2014-02-06")) # Thu: 9 - 2 = 7 -> fomc_w1
get_day_in_fomc_cycle(fomc_test_date, as.Date("2014-02-07")) # Fri: 10 - 2 = 8 -> fomc_w1
get_day_in_fomc_cycle(fomc_test_date, as.Date("2014-02-08")) # Sat: 9 -> NULL
get_day_in_fomc_cycle(fomc_test_date, as.Date("2014-02-09")) # Sun: 10 -> NULL
get_day_in_fomc_cycle(fomc_test_date, as.Date("2014-02-10")) # Mon: 11 - 2 = 9 -> fomc_w2
get_day_in_fomc_cycle(fomc_test_date, as.Date("2014-02-10")) # Mon: 12 - 2 = 10 -> fomc_w2











current_path = rstudioapi::getActiveDocumentContext()$path
setwd(dirname(current_path))


fomc_data <- read_excel(
  '../data/FOMC_Cycle_dates_2014_2016.xlsx', 
  sheet = 1,
  col_names = c("Startdate", "Enddate", "Notes"),
  col_types = c("date", "date", "text"),
  skip = 10)

fomc_start_dates <- rev(fomc_data$Startdate) # Reverse FOMC start dates in .xlsx File

us_returns_df <- read.csv('us_returns_df_2014_2016.csv')

us_returns_df


