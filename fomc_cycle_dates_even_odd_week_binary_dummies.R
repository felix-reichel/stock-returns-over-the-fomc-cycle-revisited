# Functions

#is_odd_or_even_date_in_fomc_cycle <- function(fomc_start_date, date) {
#  diff_weeks_numeric <- difftime(date, fomc_start_date, units = "weeks")
#  diff_weeks_integer <- floor(diff_weeks_numeric)
#  if ( as.integer(diff_weeks_integer) %% 2 == 0 ) { # return(as.integer(diff_weeks_integer) %% 2 == 0) 
#    return(1)  
#  } else {
#    return(0)  
#  }
# = TRUE/1 for days in even week within the FOMC Cycle counting from 0. (0,2,4,6)
# = FALSE/0 for days in odd week within the FOMC Cycle. (1,3,5)
# }

is_date_in_t_floor_week_within_fomc_cycle <- function(fomc_start_date, date, t_floor_week) {
  diff_weeks_numeric <- difftime(date, fomc_start_date, units = "weeks")
  diff_weeks_integer <- floor(diff_weeks_numeric)
  if ( diff_weeks_integer == t_floor_week ) {
    return(1)
  } else {
    return(0)
  }
}


is_date_in_ge_7_floor_week_within_fomc_cycle <- function(fomc_start_date, date) {
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

fomc_start_dates <- rev(fomc_data$Startdate) # reverse fomc start dates

# create empty vectors
dates <- c()
# is_in_even_fomc_week <- c()

# 7 week dummies
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
      
    # in_even_or_odd_week <- is_odd_or_even_date_in_fomc_cycle(
    #                                                        prev_fomc_start_date, 
    #                                                        date)
    
    
    dates <- c(dates, date)
    # is_in_even_fomc_week <- c(is_in_even_fomc_week, in_even_or_odd_week)
    
    # generate week dummies
    is_date_in_0_week <- is_date_in_t_floor_week_within_fomc_cycle(prev_fomc_start_date, date, 0)
    is_date_in_1_week <- is_date_in_t_floor_week_within_fomc_cycle(prev_fomc_start_date, date, 1)
    is_date_in_2_week <- is_date_in_t_floor_week_within_fomc_cycle(prev_fomc_start_date, date, 2)
    is_date_in_3_week <- is_date_in_t_floor_week_within_fomc_cycle(prev_fomc_start_date, date, 3)
    is_date_in_4_week <- is_date_in_t_floor_week_within_fomc_cycle(prev_fomc_start_date, date, 4)
    is_date_in_5_week <- is_date_in_t_floor_week_within_fomc_cycle(prev_fomc_start_date, date, 5)
    is_date_in_6_week <- is_date_in_t_floor_week_within_fomc_cycle(prev_fomc_start_date, date, 6)
    is_date_in_ge7_week <- is_date_in_ge_7_floor_week_within_fomc_cycle(prev_fomc_start_date, date)
    
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
# with Ex-ante (shifted t-x weeks) dummies where x of integer set {0,1,2,3,4,5,6}.
# dummies_len <- length(is_in_even_fomc_week)
week_len <- 7

# Testing stored vector dates
# as.Date(dates[1], origin = lubridate::origin)
# [1] "2018-01-30"
# as.Date(dates[(dummies_len - (week_len * 7))], origin = lubridate::origin)
# "2023-01-30"
# as.Date(dates[dummies_len], origin = lubridate::origin)
# "2023-03-20"
# as.Date(dates[dummies_len+1], origin = lubridate::origin)
# [1] NA


df <- data.frame(
  # date = as.Date(dates[1 : (dummies_len - (week_len * 7)) ], origin = lubridate::origin),
  # dummy0 = is_in_even_fomc_week[1 : (dummies_len - (week_len * 7)) ],
  # dummy1 = is_in_even_fomc_week[((week_len * 1) + 1) : (dummies_len - (week_len * 6))],
  # dummy2 = is_in_even_fomc_week[((week_len * 2) + 1) : (dummies_len - (week_len * 5))],
  # dummy3 = is_in_even_fomc_week[((week_len * 3) + 1) : (dummies_len - (week_len * 4))],
  # dummy4 = is_in_even_fomc_week[((week_len * 4) + 1) : (dummies_len - (week_len * 3))],
  # dummy5 = is_in_even_fomc_week[((week_len * 5) + 1) : (dummies_len - (week_len * 2))],
  # dummy6 = is_in_even_fomc_week[((week_len * 6) + 1) : (dummies_len - (week_len * 1))],
  # dummy7 = is_in_even_fomc_week[((week_len * 7) + 1) :  dummies_len]

  date = as.Date(dates, origin = lubridate::origin),
  # 7 week dummies for approx. 6.5 ordinary FOMC cycle time.
  w_t0 = w_t0, # even
  w_t1 = w_t1, 
  w_t2 = w_t2, # even
  w_t3 = w_t3,
  w_t4 = w_t4, # even
  w_t5 = w_t5,
  w_t6 = w_t6,  # even
  # 8th dummy variable for unordinary FOMC cycle times
  w_ge_t7 = w_tge7,
  row.names = FALSE
)

# Write csv containing FOMC odd/even week dummies
write.csv(df, 'data/dates_is_in_even_fomc_week_dummies.csv')




