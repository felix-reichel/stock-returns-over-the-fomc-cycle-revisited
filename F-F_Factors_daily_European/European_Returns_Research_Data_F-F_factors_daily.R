library(readxl)

current_path <- rstudioapi::getActiveDocumentContext()$path
setwd(dirname(current_path))

# Read the Fama-French daily factors data from CSV file
european_returns <- read.csv('Europe_3_Factors_Daily.csv', col.names = c("DATE", "Mkt-RF", "SMB", "HML", "RF"), skip = 7)

# Extract relevant date range
date_format <- "%Y%m%d"
european_returns$DATE <- as.Date(as.character(european_returns$DATE), format = date_format)
start_date <- as.Date("1993-12-31", format = "%Y-%m-%d")
end_date <- as.Date("2023-09-29", format = "%Y-%m-%d")
european_returns_df <- subset(
  european_returns,
  DATE >= start_date & DATE <= end_date
)

# Change the date format to yyyy-mm-dd
new_date_format <- "%Y-%m-%d"
european_returns_df$DATE <- format(european_returns_df$DATE, format = new_date_format)

# Write the subsetted data frame to a new CSV file
write.csv(
  european_returns_df,
  'european_returns_df_1994_sept2023.csv',
  row.names = FALSE
)
