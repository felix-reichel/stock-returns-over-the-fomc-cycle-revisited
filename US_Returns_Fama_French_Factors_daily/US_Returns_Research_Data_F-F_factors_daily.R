library(readxl)

current_path = rstudioapi::getActiveDocumentContext()$path
setwd(dirname(current_path))

# Read the Fama-French daily factors data from CSV file
us_returns <- read.csv('F-F_Research_Data_Factors_daily_nov2023.CSV', col.names = c("DATE", "Mkt-RF", "SMB", "HML", "RF"), skip = 4)

# Extract relevant date range
date_format <- "%Y%m%d"
us_returns$DATE <- as.Date(us_returns$DATE, format = date_format)
us_returns_df <- subset(
  us_returns,
  DATE >= as.Date("1993-12-31") & DATE <= as.Date("2023-01-03")
)

# Write the subsetted data frame to a new CSV file
write.csv(
  us_returns_df,
  'us_returns_df_1994_nov2023.csv',
  row.names = FALSE
)