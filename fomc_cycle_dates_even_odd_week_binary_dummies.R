# Functions
is_odd_or_even_date_in_fomc_cycle <- function(fomc_start_date, date) {
  diff_weeks_numeric <- difftime(date, fomc_start_date, units = "weeks")
  diff_weeks_integer <- floor(diff_weeks_numeric)
  return(as.integer(diff_weeks_integer) %% 2 == 0) 
  # = TRUE for days in even week within the FOMC Cycle counting from 0. (0,2,4,6)
  # = FALSE for days in odd week within the FOMC Cycle. (1,3,5,7)
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

fomc_start_dates <- rev(fomc_data$Startdate) # reverse start dates

# create two empty vectors
dates <- c()
is_in_even_fomc_week <- c()

prev_fomc_start_date <- as.Date(fomc_start_dates[1])  # = First FOMC meeting start date 
length <- length(fomc_start_dates)
remaining_fomc_start_dates <- as.Date(fomc_start_dates[2:length])


for (next_fomc_start_date in remaining_fomc_start_dates) {
    
    next_fomc_start_date <- as.Date(next_fomc_start_date, origin = lubridate::origin)
    prev_fomc_start_date <- as.Date(prev_fomc_start_date, origin = lubridate::origin)

    # create sequence for days in [ prev_fomc_start_date, next_fomc_start_date ]
    days_between_fomc_meetings_seq <- seq(prev_fomc_start_date, next_fomc_start_date, "day")
    
    # WIP/TODO: There are duplicates because of '[' vs. ']'
    # see 'data/dates_is_in_even_fomc_week_dummies.csv':
    #   "50",17610,FALSE
    #   "51",17610,TRUE

    for (date in days_between_fomc_meetings_seq) {

      date <- as.Date(date, origin = lubridate::origin)
      
      in_even_or_odd_week <- is_odd_or_even_date_in_fomc_cycle(
                                prev_fomc_start_date, 
                                date)
      
      dates <- c(dates, date)
      is_in_even_fomc_week <- c(is_in_even_fomc_week, in_even_or_odd_week)
    
    }
    prev_fomc_start_date <- next_fomc_start_date
}

# create dataframe
df <- data.frame(
  dates = dates, 
  is_in_even_fomc_week = is_in_even_fomc_week
)

# write csv containing fomc odd/even week dummies
write.csv(df, 'data/dates_is_in_even_fomc_week_dummies.csv')




