require(quantmod)
require(xts)
require(astsa) 
require(tseries)

current_path = rstudioapi::getActiveDocumentContext()$path
setwd(dirname(current_path))

# Get S&P500 from 2014-01-28 to 2016-12-13
getSymbols.FRED(c("SP500"), auto.assign = TRUE, env = globalenv())

# Jfyi: Data misses holidays and weekends
xtsJan14dec16 <- SP500["2014-01-28/2016-12-13"]

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
kpss.test(sp500_d1, null= "Level")  # p-value = 0.1 < 0.05 => H1 => Level Stationarity 
kpss.test(sp500_d1, null = "Trend") # p-value = 0.1 < 0.05 => H1 => Trend Stationarity 


mean(diff(sp500))
mean(diff(sp500_d1))
plot(diff(sp500_d1), type = 'l')

# Create data.frame
sp500_df <- data.frame(
  date = index(xtsJan14dec16),
  sp500 = sp500,
  sp500_d1 = round(c(sp500_d1, 0), digits = 2)
)

# Write csv
write.csv(sp500_df, 'sp500_df_2014_2016.csv', row.names = FALSE)

