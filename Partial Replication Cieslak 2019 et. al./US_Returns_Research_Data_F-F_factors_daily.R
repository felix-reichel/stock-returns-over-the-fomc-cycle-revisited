library(readxl)

current_path = rstudioapi::getActiveDocumentContext()$path
setwd(dirname(current_path))

# us_returns <- read.csv('F-F_Research_Data_Factors_daily.CSV', col.names = c("DATE", "Mkt-RF", "SMB", "HML", "RF"), skip = 4)


us_returns2 <- read_excel(
  'F-F_Research_Data_Factors_daily_wb.xlsx', 
  sheet = 1,
  col_names = c("DATE",
                "Mkt-RF",
                "SMB", 
                "HML", 
                "RF", 
                "Excess Returns t+1 on 100",
                "Mkt-RF multiplicator", 
                "Excess Returns t+5 on 100"),
  col_types = c("text", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric", "numeric"),
  skip = 5)



date_format <- "%Y%m%d"
#us_returns_dates <- as.Date(x = us_returns$DATE, format = date_format)
us_returns_dates <- as.Date(x = us_returns2$DATE, format = date_format)


x1_date <- as.Date("2010-01-25")
x2_date <- as.Date("2016-12-30")
x1_idx <- which(us_returns_dates == x1_date)
x2_idx <- which(us_returns_dates == x2_date)

us_returns_df <- data.frame(
  date = us_returns_dates[x1_idx:x2_idx],
  Mkt.RF = us_returns2$`Mkt-RF`[x1_idx:x2_idx],
  SMB = us_returns2$SMB[x1_idx:x2_idx],
  HML = us_returns2$HML[x1_idx:x2_idx],
  RF = us_returns2$RF[x1_idx:x2_idx],
  Exc_ret_t1 = us_returns2$`Excess Returns t+1 on 100`[x1_idx:x2_idx],
  Exc_ret_t5 = us_returns2$`Excess Returns t+5 on 100`[x1_idx:x2_idx],
  Mkt.RF.mult = us_returns2$`Mkt-RF multiplicator`[x1_idx:x2_idx]
)


# Write csv
write.csv(us_returns_df, 'us_returns_df_2010_2016.csv', row.names = FALSE)
