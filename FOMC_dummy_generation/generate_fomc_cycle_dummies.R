# Load required libraries
library(readxl)
library(lubridate)

current_path = rstudioapi::getActiveDocumentContext()$path
setwd(dirname(current_path))

# Define constants
monday <- 1
saturday <- 6
sunday <- 7
weekend_duration <- 2

# Define FOMC cycle patterns
fomc_wm1 <- c(-6:-2)
fomc_w0 <- c(-1:3)
fomc_w1 <- c(4:8)
fomc_w2 <- c(9:13)
fomc_w3 <- c(14:18)
fomc_w4 <- c(19:23)
fomc_w5 <- c(24:28)
fomc_w6 <- c(29:33)

# Combine FOMC patterns into a cycle
fomc_cycle <- c(fomc_wm1, fomc_w0, fomc_w1, fomc_w2, fomc_w3, fomc_w4, fomc_w5, fomc_w6)

# Function to calculate time difference in weeks
get_difftime_weeks <- function(fomc_meeting_date, date) {
  weekday_of_fomc_meeting_date <- wday(fomc_meeting_date, week_start = monday)
  adjusted_fomc_meeting_date <- fomc_meeting_date - days(weekday_of_fomc_meeting_date)
  return(floor(difftime(date, adjusted_fomc_meeting_date, units = "weeks")))
}

# Function to get FOMC day within the cycle
get_fomc_day_within_fomc_cycle <- function(fomc_meeting_date, date) {
  weekday_of_date <- wday(date, week_start = monday)
  if (weekday_of_date %in% c(saturday, sunday)) return(NULL)
  weekday_of_fomc_meeting_date <- wday(fomc_meeting_date, week_start = monday)
  difftime_days <- as.integer(difftime(date, fomc_meeting_date, units = "days"))
  occurred_weekends <- get_difftime_weeks(fomc_meeting_date, date)
  as.integer(difftime_days - (weekend_duration * occurred_weekends))
}

# Function to get next dummy value
get_next_dummy_value <- function(fomc_cycle_day, fomc_w) as.integer(fomc_cycle_day %in% fomc_w)

# Set working directory
current_path <- rstudioapi::getActiveDocumentContext()$path
setwd(dirname(current_path))

# Read FOMC data
fomc_data <- read_excel(
  'FOMC_Cycle_dates_1994_nov2023.xlsx', 
  sheet = 1,
  col_names = c("Startdate", "Enddate", "start_less_end_bool"),
  col_types = c("date", "date", "logical"),
  skip = 10
)

# Initialize vectors for FOMC cycle week dummies
dates <- w_t0 <- w_t1 <- w_t2 <- w_t3 <- w_t4 <- w_t5 <- w_t6 <- w_tm1 <- w_cluster <- fomc_d <- w_even <- w_t2t4t6 <- c()

# Process FOMC start dates
fomc_start_dates <- rev(fomc_data$Enddate)
first_fomc_start_date <- as.Date(fomc_start_dates[1])
adj_first_fomc_start_date <- ymd(first_fomc_start_date) - days(as.integer(wday(first_fomc_start_date, week_start = monday))) - days(7)
prev_fomc_start_date <- first_fomc_start_date
length <- length(fomc_start_dates)
remaining_fomc_start_dates <- as.Date(fomc_start_dates[2:length])

# Loop through FOMC start dates
for (next_fomc_start_date in remaining_fomc_start_dates) {
  next_fomc_start_date <- as.Date(next_fomc_start_date, origin = lubridate::origin)
  prev_fomc_start_date <- as.Date(prev_fomc_start_date, origin = lubridate::origin)
  adj_prev_fomc_start_date <- ymd(prev_fomc_start_date) - days(as.integer(wday(prev_fomc_start_date, week_start = monday))) - days(7)
  adj_next_fomc_start_date <- ymd(next_fomc_start_date) - days(as.integer(wday(next_fomc_start_date, week_start = monday))) - days(7)
  
  # Generate sequence of days between FOMC meetings
  days_between_fomc_meetings_seq <- seq(adj_prev_fomc_start_date + days(1), adj_next_fomc_start_date + days(1), "day")
  
  # Loop through days between FOMC meetings
  for (date in days_between_fomc_meetings_seq) {
    date <- as.Date(date, origin = lubridate::origin)
    fomc_cycle_day <- get_fomc_day_within_fomc_cycle(prev_fomc_start_date, date)
    
    # Check conditions for dummy values
    if (!is.null(fomc_cycle_day) && fomc_cycle_day %in% fomc_cycle) {
      dates <- c(dates, date)
      fomc_d <- c(fomc_d, fomc_cycle_day)
      w_cluster <- c(w_cluster, get_difftime_weeks(first_fomc_start_date, date) + 1)
      w_even <- c(w_even, get_next_dummy_value(fomc_cycle_day, c(fomc_w0, fomc_w2, fomc_w4, fomc_w6)))
      w_t2t4t6 <- c(w_t2t4t6, get_next_dummy_value(fomc_cycle_day, c(fomc_w2, fomc_w4, fomc_w6)))
      w_t0 <- c(w_t0, get_next_dummy_value(fomc_cycle_day, fomc_w0))
      w_t1 <- c(w_t1, get_next_dummy_value(fomc_cycle_day, fomc_w1))
      w_t2 <- c(w_t2, get_next_dummy_value(fomc_cycle_day, fomc_w2))
      w_t3 <- c(w_t3, get_next_dummy_value(fomc_cycle_day, fomc_w3))
      w_t4 <- c(w_t4, get_next_dummy_value(fomc_cycle_day, fomc_w4))
      w_t5 <- c(w_t5, get_next_dummy_value(fomc_cycle_day, fomc_w5))
      w_t6 <- c(w_t6, get_next_dummy_value(fomc_cycle_day, fomc_w6))
      w_tm1 <- c(w_tm1, get_next_dummy_value(fomc_cycle_day, fomc_wm1))
    }
  }
  prev_fomc_start_date <- next_fomc_start_date
}

# Create a data frame with the results
df <- data.frame(
  date = as.Date(dates, origin = lubridate::origin),
  w_t0 = w_t0,
  w_t1 = w_t1, 
  w_t2 = w_t2,
  w_t3 = w_t3,
  w_t4 = w_t4,
  w_t5 = w_t5,
  w_t6 = w_t6,
  w_cluster = w_cluster,
  w_tm1 = w_tm1,
  fomc_d = fomc_d,
  w_even = w_even,
  w_t2t4t6 = w_t2t4t6
)

# Write the results to a CSV file
write.csv(df, 'fomc_week_dummies_1994_nov2023.csv', row.names = FALSE)

# Run tests
testthat::test_dir('tests')
