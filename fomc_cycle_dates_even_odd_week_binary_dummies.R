# Functions
is_date_in_t_floor_week_within_fomc_cycle <- function(fomc_start_date, date, t_floor_week) {
  diff_weeks_numeric <- difftime(date, fomc_start_date, units = "weeks")
  diff_weeks_integer <- floor(diff_weeks_numeric)
  if ( diff_weeks_integer == t_floor_week ) {
    return(1) 
  } else {
    return(0)
  }
}

is_date_in_greater_or_equal_7_floor_week_within_fomc_cycle <- function(fomc_start_date, date) {
  diff_weeks_numeric <- difftime(date, fomc_start_date, units = "weeks")
  diff_weeks_integer <- floor(diff_weeks_numeric)
  if ( diff_weeks_integer >= 7 ) {
    return(1)
  } else {
    return(0)
  }
}

install.packages('readxl')
library(readxl)
library(lubridate)

current_path = rstudioapi::getActiveDocumentContext()$path
setwd(dirname(current_path))

fomc_data <- read_excel(
  'data/FOMC_Cycle_dates_2018_mar2023.xlsx', 
  sheet = 1,
  col_names = c("Startdate", "Enddate", "Notes"),
  col_types = c("date", "date", "text"),
  skip = 10)

fomc_start_dates <- rev(fomc_data$Startdate) # Reverse FOMC start dates in .xlsx File

# create empty vectors
dates <- c()
# 7 FOMC cycle week dummies
w_t0 <- c()
w_t1 <- c()
w_t2 <- c()
w_t3 <- c()
w_t4 <- c()
w_t5 <- c()
w_t6 <- c()
w_tge7 <- c()

prev_fomc_start_date <- as.Date(fomc_start_dates[1])  # = First FOMC meeting start date 
length <- length(fomc_start_dates)
remaining_fomc_start_dates <- as.Date(fomc_start_dates[2:length])


for (next_fomc_start_date in remaining_fomc_start_dates) {
    
  next_fomc_start_date <- as.Date(next_fomc_start_date, origin = lubridate::origin)
  prev_fomc_start_date <- as.Date(prev_fomc_start_date, origin = lubridate::origin)

  next_fomc_start_date_minus_1_day <- ymd(next_fomc_start_date) - days(1)

  # create sequence for days in [ prev_fomc_start_date, next_fomc_start_date_minus_1_day ]
  days_between_fomc_meetings_seq <- seq(
                                        prev_fomc_start_date,
                                        next_fomc_start_date_minus_1_day,
                                        "day"
                                        )
  for (date in days_between_fomc_meetings_seq) {

    date <- as.Date(date, origin = lubridate::origin)
    dates <- c(dates, date)
    
    # generate FOMC cycle week dummies
    is_date_in_0_week <- is_date_in_t_floor_week_within_fomc_cycle(prev_fomc_start_date, date, 0)
    is_date_in_1_week <- is_date_in_t_floor_week_within_fomc_cycle(prev_fomc_start_date, date, 1)
    is_date_in_2_week <- is_date_in_t_floor_week_within_fomc_cycle(prev_fomc_start_date, date, 2)
    is_date_in_3_week <- is_date_in_t_floor_week_within_fomc_cycle(prev_fomc_start_date, date, 3)
    is_date_in_4_week <- is_date_in_t_floor_week_within_fomc_cycle(prev_fomc_start_date, date, 4)
    is_date_in_5_week <- is_date_in_t_floor_week_within_fomc_cycle(prev_fomc_start_date, date, 5)
    is_date_in_6_week <- is_date_in_t_floor_week_within_fomc_cycle(prev_fomc_start_date, date, 6)
    is_date_in_ge7_week <- is_date_in_greater_or_equal_7_floor_week_within_fomc_cycle(prev_fomc_start_date, date)
    
    # append dummies to vectors
    w_t0 <- c(w_t0, is_date_in_0_week)
    w_t1 <- c(w_t1, is_date_in_1_week)
    w_t2 <- c(w_t2, is_date_in_2_week)
    w_t3 <- c(w_t3, is_date_in_3_week)
    w_t4 <- c(w_t4, is_date_in_4_week)
    w_t5 <- c(w_t5, is_date_in_5_week)
    w_t6 <- c(w_t6, is_date_in_6_week)
    w_tge7 <- c(w_tge7, is_date_in_ge7_week)
  }

  prev_fomc_start_date <- next_fomc_start_date
}

# Create dataframe 
week_len <- 7

df <- data.frame(
  date = as.Date(dates, origin = lubridate::origin),
  w_t0 = w_t6,
  w_t1 = w_t5, 
  w_t2 = w_t4,
  w_t3 = w_t3,
  w_t4 = w_t2,
  w_t5 = w_t1,
  w_t6 = w_t0
)

# Write csv containing FOMC odd/even week dummies
write.csv(df, 'data/dates_is_in_even_fomc_week_dummies.csv', row.names = FALSE)

