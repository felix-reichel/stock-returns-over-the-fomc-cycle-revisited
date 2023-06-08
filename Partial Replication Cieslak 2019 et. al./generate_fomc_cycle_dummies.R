week_len <- 7
# Functions
get_day_in_week_ordinal_rank_within_fomc_cycle <- function(fomc_start_date, date) {
  diff_days <- difftime(date, fomc_start_date, units = "days")
  return(as.integer(floor(diff_days)) %% week_len * 2 )
}


is_date_in_even_week_within_fomc_cycle <- function(fomc_start_date, date, t_floor_week) {
  diff_weeks_numeric <- difftime(date, fomc_start_date, units = "weeks")
  diff_weeks_integer <- as.integer(floor(diff_weeks_numeric))

  if (diff_weeks_integer %% 2 == 0) {
    return(1) 
  } else {
    return(0)
  }
}

# get_day_in_week_ordinal_rank_within_fomc_cycle(as.Date("2014-01-28"),as.Date("2014-01-31"))

install.packages('readxl')
library(readxl)
library(lubridate)

current_path = rstudioapi::getActiveDocumentContext()$path
setwd(dirname(current_path))

fomc_data <- read_excel(
  '../data/FOMC_Cycle_dates_2014_2016.xlsx', 
  sheet = 1,
  col_names = c("Startdate", "Enddate", "Notes"),
  col_types = c("date", "date", "text"),
  skip = 10)

fomc_start_dates <- rev(fomc_data$Startdate) # Reverse FOMC start dates in .xlsx File

# create empty vectors
dates <- c()
# create 7 FOMC cycle weekday dummies
w_t0_e <- c()
w_t1_e <- c()
w_t2_e <- c()
w_t3_e <- c()
w_t4_e <- c()
w_t5_e <- c()
w_t6_e <- c()

w_t0_o <- c()
w_t1_o <- c()
w_t2_o <- c()
w_t3_o <- c()
w_t4_o <- c()
w_t5_o <- c()
w_t6_o <- c()

fomc_even_w <- c()
fomc_odd_w <- c()

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
    

    day_rnk <- as.integer(get_day_in_week_ordinal_rank_within_fomc_cycle(prev_fomc_start_date, date))
    
    is_date_in_even_week <- is_date_in_even_week_within_fomc_cycle(prev_fomc_start_date, date)
    
    fomc_even_w <- c(fomc_even_w, is_date_in_even_week)
    
    # THIS PART IS UTTERLY STUPID.
    # TODO: Rewrite this later 
    if (is_date_in_even_week == 1) {
      
      if (day_rnk == 0) {  # monday
        w_t0_e <- c(w_t0_e, 1)
        w_t1_e <- c(w_t1_e, 0)
        w_t2_e <- c(w_t2_e, 0)
        w_t3_e <- c(w_t3_e, 0)
        w_t4_e <- c(w_t4_e, 0)
        w_t5_e <- c(w_t5_e, 0)
        w_t6_e <- c(w_t6_e, 0)
      }
      if (day_rnk == 1) {
        w_t0_e <- c(w_t0_e, 0)
        w_t1_e <- c(w_t1_e, 1)
        w_t2_e <- c(w_t2_e, 0)
        w_t3_e <- c(w_t3_e, 0)
        w_t4_e <- c(w_t4_e, 0)
        w_t5_e <- c(w_t5_e, 0)
        w_t6_e <- c(w_t6_e, 0)
      }
      if (day_rnk == 2) {
        w_t0_e <- c(w_t0_e, 0)
        w_t1_e <- c(w_t1_e, 0)
        w_t2_e <- c(w_t2_e, 1)
        w_t3_e <- c(w_t3_e, 0)
        w_t4_e <- c(w_t4_e, 0)
        w_t5_e <- c(w_t5_e, 0)
        w_t6_e <- c(w_t6_e, 0)
      }
      if (day_rnk == 3) {
        w_t0_e <- c(w_t0_e, 0)
        w_t1_e <- c(w_t1_e, 0)
        w_t2_e <- c(w_t2_e, 0)
        w_t3_e <- c(w_t3_e, 1)
        w_t4_e <- c(w_t4_e, 0)
        w_t5_e <- c(w_t5_e, 0)
        w_t6_e <- c(w_t6_e, 0)
      }
      if (day_rnk == 4) {
        w_t0_e <- c(w_t0_e, 0)
        w_t1_e <- c(w_t1_e, 0)
        w_t2_e <- c(w_t2_e, 0)
        w_t3_e <- c(w_t3_e, 0)
        w_t4_e <- c(w_t4_e, 1)
        w_t5_e <- c(w_t5_e, 0)
        w_t6_e <- c(w_t6_e, 0)
      }
      if (day_rnk == 5) {
        w_t0_e <- c(w_t0_e, 0)
        w_t1_e <- c(w_t1_e, 0)
        w_t2_e <- c(w_t2_e, 0)
        w_t3_e <- c(w_t3_e, 0)
        w_t4_e <- c(w_t4_e, 0)
        w_t5_e <- c(w_t5_e, 1)
        w_t6_e <- c(w_t6_e, 0)
      }
      if (day_rnk == 6) {
        w_t0_e <- c(w_t0_e, 0)
        w_t1_e <- c(w_t1_e, 0)
        w_t2_e <- c(w_t2_e, 0)
        w_t3_e <- c(w_t3_e, 0)
        w_t4_e <- c(w_t4_e, 0)
        w_t5_e <- c(w_t5_e, 0)
        w_t6_e <- c(w_t6_e, 1)
      }
      
      w_t0_o <- c(w_t0_o, 0)
      w_t1_o <- c(w_t1_o, 0)
      w_t2_o <- c(w_t2_o, 0)
      w_t3_o <- c(w_t3_o, 0)
      w_t4_o <- c(w_t4_o, 0)
      w_t5_o <- c(w_t5_o, 0)
      w_t6_o <- c(w_t6_o, 0)
      
    } else {
      
      w_t0_e <- c(w_t0_e, 0)
      w_t1_e <- c(w_t1_e, 0)
      w_t2_e <- c(w_t2_e, 0)
      w_t3_e <- c(w_t3_e, 0)
      w_t4_e <- c(w_t4_e, 0)
      w_t5_e <- c(w_t5_e, 0)
      w_t6_e <- c(w_t6_e, 0)
      
      if (day_rnk == 0) {  # monday
        w_t0_o <- c(w_t0_o, 1)
        w_t1_o <- c(w_t1_o, 0)
        w_t2_o <- c(w_t2_o, 0)
        w_t3_o <- c(w_t3_o, 0)
        w_t4_o <- c(w_t4_o, 0)
        w_t5_o <- c(w_t5_o, 0)
        w_t6_o <- c(w_t6_o, 0)
      }
      
      if (day_rnk == 1) {
        w_t0_o <- c(w_t0_o, 0)
        w_t1_o <- c(w_t1_o, 1)
        w_t2_o <- c(w_t2_o, 0)
        w_t3_o <- c(w_t3_o, 0)
        w_t4_o <- c(w_t4_o, 0)
        w_t5_o <- c(w_t5_o, 0)
        w_t6_o <- c(w_t6_o, 0)
      }
      
      if (day_rnk == 2) {
        w_t0_o <- c(w_t0_o, 0)
        w_t1_o <- c(w_t1_o, 0)
        w_t2_o <- c(w_t2_o, 1)
        w_t3_o <- c(w_t3_o, 0)
        w_t4_o <- c(w_t4_o, 0)
        w_t5_o <- c(w_t5_o, 0)
        w_t6_o <- c(w_t6_o, 0)
      }
      
      if (day_rnk == 3) {
        w_t0_o <- c(w_t0_o, 0)
        w_t1_o <- c(w_t1_o, 0)
        w_t2_o <- c(w_t2_o, 0)
        w_t3_o <- c(w_t3_o, 1)
        w_t4_o <- c(w_t4_o, 0)
        w_t5_o <- c(w_t5_o, 0)
        w_t6_o <- c(w_t6_o, 0)
      }
      if (day_rnk == 4) {
        w_t0_o <- c(w_t0_o, 0)
        w_t1_o <- c(w_t1_o, 0)
        w_t2_o <- c(w_t2_o, 0)
        w_t3_o <- c(w_t3_o, 0)
        w_t4_o <- c(w_t4_o, 1)
        w_t5_o <- c(w_t5_o, 0)
        w_t6_o <- c(w_t6_o, 0)
      }
      if (day_rnk == 5) {
        w_t0_o <- c(w_t0_o, 0)
        w_t1_o <- c(w_t1_o, 0)
        w_t2_o <- c(w_t2_o, 0)
        w_t3_o <- c(w_t3_o, 0)
        w_t4_o <- c(w_t4_o, 0)
        w_t5_o <- c(w_t5_o, 1)
        w_t6_o <- c(w_t6_o, 0)
      }
      if (day_rnk == 6) {
        w_t0_o <- c(w_t0_o, 0)
        w_t1_o <- c(w_t1_o, 0)
        w_t2_o <- c(w_t2_o, 0)
        w_t3_o <- c(w_t3_o, 0)
        w_t4_o <- c(w_t4_o, 0)
        w_t5_o <- c(w_t5_o, 0)
        w_t6_o <- c(w_t6_o, 1)
      }
    }
  }

  prev_fomc_start_date <- next_fomc_start_date
}

df <- data.frame(
  date = as.Date(dates, origin = lubridate::origin),
  w_t0_e = w_t0_e,
  w_t1_e = w_t1_e, 
  w_t2_e = w_t2_e,
  w_t3_e = w_t3_e,
  w_t4_e = w_t4_e,
  w_t5_e = w_t5_e,
  w_t6_e = w_t6_e,
  w_t0_o = w_t0_o,
  w_t1_o = w_t1_o, 
  w_t2_o = w_t2_o,
  w_t3_o = w_t3_o,
  w_t4_o = w_t4_o,
  w_t5_o = w_t5_o,
  w_t6_o = w_t6_o,
  fomc_even_w = fomc_even_w
)

# Write csv containing FOMC odd/even WEEKDAY dummies
write.csv(df, 'fomc_week_dummies_2014_2016.csv', row.names = FALSE)

