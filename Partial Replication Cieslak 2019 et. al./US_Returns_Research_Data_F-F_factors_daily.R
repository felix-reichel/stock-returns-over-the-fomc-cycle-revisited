library(readxl)

current_path = rstudioapi::getActiveDocumentContext()$path
setwd(dirname(current_path))

us_returns2 <- read.csv('F-F_Research_Data_Factors_daily.CSV', col.names = c("DATE", "Mkt-RF", "SMB", "HML", "RF"), skip = 4)


#us_returns2 <- read_excel(
#  'North_America_3_Factors_Daily.xlsx', 
#  sheet = 1,
#  col_names = c("DATE",
#                "Mkt-RF",
#                "SMB", 
#                "HML", 
#                "RF", 
#                "Avg. 5d fw Mkt-RF"),
#  col_types = c("text", "numeric", "numeric", "numeric", "numeric", "numeric"),
#  skip = 8)



date_format <- "%Y%m%d"
#us_returns_dates <- as.Date(x = us_returns$DATE, format = date_format)
us_returns_dates <- as.Date(x = us_returns2$DATE, format = date_format)


x1_date <- as.Date("2010-01-25")
x2_date <- as.Date("2016-12-30")
x1_idx <- which(us_returns_dates == x1_date)
x2_idx <- which(us_returns_dates == x2_date)

us_returns_df <- data.frame(
  date = us_returns_dates[x1_idx:x2_idx],
  Mkt.RF = us_returns2$Mkt.RF[x1_idx:x2_idx],
  SMB = us_returns2$SMB[x1_idx:x2_idx],
  HML = us_returns2$HML[x1_idx:x2_idx],
  RF = us_returns2$RF[x1_idx:x2_idx]#,
  #Mkt.RF.avg5d = us_returns2$`Avg. 5d fw Mkt-RF`[x1_idx:x2_idx]
)


# Write csv
write.csv(us_returns_df, 'us_returns_df_2010_2016.csv', row.names = FALSE)
