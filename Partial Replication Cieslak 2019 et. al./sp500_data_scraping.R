require(quantmod)
require(xts)
require(astsa) 
require(tseries)

current_path = rstudioapi::getActiveDocumentContext()$path
setwd(dirname(current_path))

# Get S&P500 from 2014-01-28 to 2016-12-13
getSymbols.FRED(c("SP500"), auto.assign = TRUE, env = globalenv())

# Jfyi: Data misses holidays and weekends
xtsJan14dec16 <- SP500["2014-01-01/2016-12-31"]

# Omit NA values
xtsJan14dec16 <- na.omit(xtsJan14dec16)

# plot
plot(xtsJan14dec16, main = "S&P500")

# numeric vector of sp500 values
sp500 <- as.numeric(xtsJan14dec16)


# Augmented Dickey-Fuller and Kwiatkowski–Phillips–Schmidt–Shin (KPSS) tests for time series
# d0
adf.test(sp500)                  # p-value = 0.1953 > 0.05 => H1 => No Stationary
kpss.test(sp500, null= "Level")  # p-value = 0.01 < 0.05 => H1 => No Level Stationarity 
kpss.test(sp500, null = "Trend") # p-value = 0.01 < 0.05 => H1 => No Trend Stationarity 

# d1
sp500_d1 <- diff(sp500)
plot(sp500_d1, type = 'l') 
adf.test(sp500_d1)                  # p-value = 0.01 < 0.05 => H1 => Stationary
kpss.test(sp500_d1, null= "Level")  # p-value = 0.1 > 0.05 => H1 => Level Stationarity 
kpss.test(sp500_d1, null = "Trend") # p-value = 0.1 > 0.05 => H1 => Trend Stationarity 


mean(diff(sp500))
mean(diff(sp500_d1))
plot(diff(sp500_d1), type = 'l')




sp500_lag5_fw_ts <- ts(data = c(0,0,0,0,0, sp500[1:(length(sp500)-5)]))
       
sp500_lag5_bw_ts <-ts( data = c(sp500[6:length(sp500)], 0,0,0,0,0))


plot(sp500_lag5_bw_ts[1:200], col=c("blue"), lwd=2, type='l')
lines(sp500[1:200], col=c("black"), lwd=2)
lines(sp500_lag5_fw_ts[1:200], col=c("red"), lwd=2)



vec_red <- c(sp500_lag5_fw_ts)
vec_black <- sp500
vec_blue <- c(sp500_lag5_bw_ts)

counter <- 1
vec_diff_blue_black <- c()
for (ahead in vec_blue) {
  calc_diff <- ahead - vec_black[counter]
  counter <- counter + 1
  vec_diff_blue_black <- c(vec_diff_blue_black, calc_diff)
}

plot(vec_diff_blue_black[1:700], type = 'l')
abline(h =mean(vec_diff_blue_black))

mean(vec_diff_blue_black)
mean(vec_diff_blue_black[0:700])

kpss.test(vec_diff_blue_black, null = "Trend") # .04947 < 0.05 => H1 => No Trend Stationarity 
kpss.test(diff(vec_diff_blue_black), null = "Trend") # 0.09813 > 0.05 => H1 => Trend Stationarity 

plot(diff(vec_diff_blue_black), type = 'l')
mean(diff(vec_diff_blue_black[0:700]))

# Create data.frame
sp500_df <- data.frame(
  date = index(xtsJan14dec16),
  sp500 = sp500#,#
  
  
  #sp500_d1 = round(c(sp500_d1, 0), digits = 2),
  
  #sp500_lag5_fw = sp500_lag5_fw_ts, # shift sp500 5 days forward,
  
  #sp500_lag5_bw = sp500_lag5_bw_ts, # shift sp500 5 days backward
  
  #sp500_lag5_fw_d1 = round(c(diff(sp500_lag5_fw_ts), 0), digits = 2),
  
  #sp500_lag5_bw_d1 = round(c(diff(sp500_lag5_bw_ts), 0), digits = 2),
  
  #sp500_5day_fw = round(vec_diff_blue_black, digits = 2),
  
  #sp500_5day_fw_diff = round(c(diff(vec_diff_blue_black), 0), digits = 2)

)

# Write csv
write.csv(sp500_df, 'sp500_df_2014_2016.csv', row.names = FALSE)

