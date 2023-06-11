library(readxl)
library(lubridate)

# FOMC cycle week definitions
fomc_wm1 <- c(-6:-2)
fomc_w0 <- c(-1:3)
fomc_w1 <- c(4:8)
fomc_w2 <- c(9:13)
fomc_w3 <- c(14:18)
fomc_w4 <- c(19:23)
fomc_w5 <- c(24:28)
fomc_w6 <- c(29:33)
fomc_w7 <- c(34:38)


fomc_cycle <- c(fomc_wm1, fomc_w0, fomc_w1, fomc_w2, fomc_w3, fomc_w4, fomc_w5, fomc_w6, fomc_w7)

monday <- 1
saturday <- 6
sunday <- 7
weekend_duration <- 2

#get_fomc_day_within_fomc_cycle <- function(fomc_meeting_date, date) {
#  weekday_of_fomc_meeting_date <- wday(fomc_meeting_date, week_start = monday)
#  difftime_days <- as.integer(difftime(date, fomc_meeting_date, units = "days"))
#  return(difftime_days)
#}

get_difftime_weeks <- function(fomc_meeting_date, date) {
  weekday_of_fomc_meeting_date <- wday(fomc_meeting_date, week_start = monday)
  adjusted_fomc_meeting_date <- fomc_meeting_date - days(weekday_of_fomc_meeting_date)
  return(floor(difftime(date, adjusted_fomc_meeting_date, units = "weeks")))
}

get_fomc_day_within_fomc_cycle <- function(fomc_meeting_date, date) {
  weekday_of_date <- wday(date, week_start = monday)
  if (weekday_of_date == saturday | weekday_of_date == sunday) {
    return(NULL)
  } 
  weekday_of_fomc_meeting_date <- wday(fomc_meeting_date, week_start = monday)
  difftime_days <- as.integer(difftime(date, fomc_meeting_date, units = "days"))
  occured_weekends <- get_difftime_weeks(fomc_meeting_date, date)
  fomc_day_within_fomc_cycle <- difftime_days - (weekend_duration * occured_weekends)
  return(fomc_day_within_fomc_cycle)
}

get_next_dummy_value <- function(fomc_cycle_day, fomc_w) {
  if (fomc_cycle_day %in% fomc_w) {
    return(1)
  } else {
    return(0)
  }
}




current_path = rstudioapi::getActiveDocumentContext()$path
setwd(dirname(current_path))


fomc_data <- read_excel(
  '../data/FOMC_Cycle_dates_2010_2016.xlsx', 
  sheet = 1,
  col_names = c("Startdate", "Enddate", "Notes"),
  col_types = c("date", "date", "text"),
  skip = 10)

# us_returns_df <- read.csv('us_returns_df_2014_2016.csv')

dates <- c()

# FOMC cycle week dummies
w_t0 <- c()
w_t1 <- c()
w_t2 <- c()
w_t3 <- c()
w_t4 <- c()
w_t5 <- c()
w_t6 <- c()
w_t7 <- c()
w_cluster <- c()
fomc_d <- c()
w_tm1 <- c()
w_even <- c()
w_t2t4t6 <- c()


fomc_start_dates <- rev(fomc_data$Startdate) # Reverse FOMC start dates in .xlsx File

first_fomc_start_date <- as.Date(fomc_start_dates[1])
prev_fomc_start_date <- first_fomc_start_date # = First FOMC meeting start date 

length <- length(fomc_start_dates)

remaining_fomc_start_dates <- as.Date(fomc_start_dates[2:length])


for (next_fomc_start_date in remaining_fomc_start_dates) {
  
  next_fomc_start_date <- as.Date(next_fomc_start_date, origin = lubridate::origin)
  prev_fomc_start_date <- as.Date(prev_fomc_start_date, origin = lubridate::origin)
  
  next_fomc_start_date_minus_3_day <- ymd(next_fomc_start_date) - days(3)
  
  # create sequence for days in [ prev_fomc_start_date, next_fomc_start_date_minus_3_day ]
  days_between_fomc_meetings_seq <- seq(
    prev_fomc_start_date - days(2),
    next_fomc_start_date_minus_3_day,
    "day"
  )
  for (date in days_between_fomc_meetings_seq) {
    
    date <- as.Date(date, origin = lubridate::origin)

    fomc_cycle_day <- get_fomc_day_within_fomc_cycle(prev_fomc_start_date, date)
    
    if (!is.null(fomc_cycle_day)) {
      if (fomc_cycle_day %in% fomc_cycle == TRUE) {
        
        dates <- c(dates, date)
        
        w_t0 <- c(w_t0, get_next_dummy_value(fomc_cycle_day, fomc_w0))
        w_t1 <- c(w_t1, get_next_dummy_value(fomc_cycle_day, fomc_w1))
        w_t2 <- c(w_t2, get_next_dummy_value(fomc_cycle_day, fomc_w2))
        w_t3 <- c(w_t3, get_next_dummy_value(fomc_cycle_day, fomc_w3))
        w_t4 <- c(w_t4, get_next_dummy_value(fomc_cycle_day, fomc_w4))
        w_t5 <- c(w_t5, get_next_dummy_value(fomc_cycle_day, fomc_w5))
        w_t6 <- c(w_t6, get_next_dummy_value(fomc_cycle_day, fomc_w6))
        w_t7 <- c(w_t7, get_next_dummy_value(fomc_cycle_day, fomc_w7))
        w_cluster <- c(w_cluster, get_difftime_weeks(first_fomc_start_date, date) + 1)
        fomc_d <- c(fomc_d, fomc_cycle_day)
        w_tm1 <- c(w_tm1, get_next_dummy_value(fomc_cycle_day, fomc_wm1))
        w_even <- c(w_even, get_next_dummy_value(fomc_cycle_day, c(fomc_w0, fomc_w2, fomc_w4, fomc_w6)))
        w_t2t4t6 <- c(w_t2t4t6, get_next_dummy_value(fomc_cycle_day, c(fomc_w2, fomc_w4, fomc_w6)))
      }
    }
  }
  
  prev_fomc_start_date <- next_fomc_start_date
}

df <- data.frame(
  date = as.Date(dates, origin = lubridate::origin),
  w_t0 = w_t0,
  w_t1 = w_t1, 
  w_t2 = w_t2,
  w_t3 = w_t3,
  w_t4 = w_t4,
  w_t5 = w_t5,
  w_t6 = w_t6,
  w_t7 = w_t7,
  w_cluster = w_cluster,
  w_tm1 = w_tm1,
  fomc_d = fomc_d,
  w_even = w_even,
  w_t2t4t6 = w_t2t4t6
)

# Write csv containing FOMC dummies
write.csv(df, 'fomc_week_dummies_2010_2016.csv', row.names = FALSE)
















# Test functions
fomc_test_date <- as.Date("2014-01-28")

# Expected return values:
get_fomc_day_within_fomc_cycle(fomc_test_date, as.Date("2014-01-25")) # NULL
get_fomc_day_within_fomc_cycle(fomc_test_date, as.Date("2014-01-26")) # NULL
get_fomc_day_within_fomc_cycle(fomc_test_date, as.Date("2014-01-27")) # Mo: -1 -> fomc_w0
get_fomc_day_within_fomc_cycle(fomc_test_date, as.Date("2014-01-28")) # Tue: 0 -> fomc_w0
get_fomc_day_within_fomc_cycle(fomc_test_date, as.Date("2014-01-29")) # Wed: 1 -> fomc_w0
get_fomc_day_within_fomc_cycle(fomc_test_date, as.Date("2014-01-30")) # Thu: 2 -> fomc_w0
get_fomc_day_within_fomc_cycle(fomc_test_date, as.Date("2014-01-31")) # Fri: 3 -> fomc_w0
get_fomc_day_within_fomc_cycle(fomc_test_date, as.Date("2014-02-01")) # Sat: 4 -> NULL
get_fomc_day_within_fomc_cycle(fomc_test_date, as.Date("2014-02-02")) # Sun: 5 -> NULL
get_fomc_day_within_fomc_cycle(fomc_test_date, as.Date("2014-02-03")) # Mo:  6 - 2 = 4 -> fomc_w1
get_fomc_day_within_fomc_cycle(fomc_test_date, as.Date("2014-02-04")) # Tue: 7 - 2 = 5 -> fomc_w1
get_fomc_day_within_fomc_cycle(fomc_test_date, as.Date("2014-02-05")) # Wed: 8 - 2 = 6 -> fomc_w1
get_fomc_day_within_fomc_cycle(fomc_test_date, as.Date("2014-02-06")) # Thu: 9 - 2 = 7 -> fomc_w1
get_fomc_day_within_fomc_cycle(fomc_test_date, as.Date("2014-02-07")) # Fri: 10 - 2 = 8 -> fomc_w1
get_fomc_day_within_fomc_cycle(fomc_test_date, as.Date("2014-02-08")) # Sat: 9 -> NULL
get_fomc_day_within_fomc_cycle(fomc_test_date, as.Date("2014-02-09")) # Sun: 10 -> NULL
get_fomc_day_within_fomc_cycle(fomc_test_date, as.Date("2014-02-10")) # Mon: 11 - 2 = 9 -> fomc_w2
get_fomc_day_within_fomc_cycle(fomc_test_date, as.Date("2014-02-11")) # Mon: 12 - 2 = 10 -> fomc_w2




