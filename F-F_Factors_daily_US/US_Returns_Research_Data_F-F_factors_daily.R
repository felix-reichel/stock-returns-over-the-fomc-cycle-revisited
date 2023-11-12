library(readxl)

current_path <- rstudioapi::getActiveDocumentContext()$path
setwd(dirname(current_path))

# Read the Fama-French daily factors data from CSV file
us_returns <- read.csv('F-F_Research_Data_Factors_daily_nov2023.CSV', col.names = c("DATE", "Mkt-RF", "SMB", "HML", "RF"), skip = 4)

# Extract relevant date range
date_format <- "%Y%m%d"
us_returns$DATE <- as.Date(as.character(us_returns$DATE), format = date_format)
start_date <- as.Date("1993-12-31", format = "%Y-%m-%d")
end_date <- as.Date("2023-10-31", format = "%Y-%m-%d")
us_returns_df <- subset(
  us_returns,
  DATE >= start_date & DATE <= end_date
)

# Change the date format to yyyy-mm-dd
new_date_format <- "%Y-%m-%d"
us_returns_df$DATE <- format(us_returns_df$DATE, format = new_date_format)

# Write the subsetted data frame to a new CSV file
write.csv(
  us_returns_df,
  'us_returns_df_1994_oct2023.csv',
  row.names = FALSE
)
