require(quantmod)
require(xts)
require(astsa) 
require(tseries)

current_path = rstudioapi::getActiveDocumentContext()$path
setwd(dirname(current_path))

# Get S&P500 from 2018-01-30 to 2023-03-20
getSymbols.FRED(c("SP500"), auto.assign = TRUE, env = globalenv())

# Jfyi: Data misses holidays and weekends
xts18mar23 <- SP500["2018-01-30/2023-03-20"]

# Omit NA values
xts18mar23 <- na.omit(xts18mar23)

# plot
plot(xts18mar23, main = "S&P500")

# numeric vector of sp500 values
sp500 <- as.numeric(xts18mar23)


# Augmented Dickey-Fuller and Kwiatkowski–Phillips–Schmidt–Shin (KPSS) tests for time series
# d0
adf.test(sp500)                  # p-value = 0.602 > 0.05 => H1 => No Stationary
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
  date = index(xts18mar23),
  sp500 = as.numeric(xts18mar23),
  sp500_d1 = round(c(sp500_d1, 0), digits = 2),
  sp500_d2_test = round(c(diff(sp500_d1), 0, 0), digits = 2)
)

# Write csv
write.csv(sp500_df, 'data/sp500_df.csv', row.names = FALSE)

