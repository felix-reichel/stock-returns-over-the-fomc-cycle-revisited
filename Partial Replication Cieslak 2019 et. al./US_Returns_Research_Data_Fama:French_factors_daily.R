current_path = rstudioapi::getActiveDocumentContext()$path
setwd(dirname(current_path))

us_returns <- read.csv('F-F_Research_Data_Factors_daily.CSV',
                       col.names = c("DATE", "Mkt-RF", "SMB", "HML", "RF"),
                       skip = 4)

date_format <- "%Y%m%d"
us_returns_dates <- as.Date(x = us_returns$DATE, format = date_format)

x1_date <- as.Date("2014-01-02")
x2_date <- as.Date("2016-12-30")
x1_idx <- which(us_returns_dates == x1_date)
x2_idx <- which(us_returns_dates == x2_date)

us_returns_df <- data.frame(
  date = us_returns_dates[x1_idx:x2_idx],
  Mkt.RF = us_returns$Mkt.RF[x1_idx:x2_idx],
  SMB = us_returns$SMB[x1_idx:x2_idx],
  HML = us_returns$HML[x1_idx:x2_idx],
  RF = us_returns$RF[x1_idx:x2_idx]
) 

# Write csv
write.csv(us_returns_df, 'us_returns_df_2014_2016.csv', row.names = FALSE)
