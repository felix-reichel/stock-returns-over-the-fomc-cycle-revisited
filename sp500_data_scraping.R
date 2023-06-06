require(quantmod)
require(xts)

# Get S&P500 from 2018-01-30 to 2023-03-20
getSymbols.FRED(c("SP500"), auto.assign = TRUE, env = globalenv())

# Jfyi: Data misses holidays and weekends

xts18mar23 <- SP500["2018-01-30/2023-03-20"]


# Clean Data
# Omit NA values
length(xts18mar23) # [1] 1340

xts18mar23 <- na.omit(xts18mar23)

length(xts18mar23) # [1] 1293

# Fill missing values using last observation
# xts_last <- na.locf(xts2)

# Fill missing values using next observation
# xts_last <- na.locf(xts2,  fromLast=TRUE)

sp500_x <- index(xts18mar23)

sp500_y <- as.numeric(xts18mar23)


# test plot S&P 500
plot(sp500_y, type = 'l', lwd=2)
plot(xts18mar23, main = "S&P 500")


# Create data.frame
sp500_df <- data.frame(
  sp500_x = sp500_x,
  sp500_y = sp500_y
)

# Write csv
write.csv(sp500_df, 'data/sp500_df.csv', row.names = FALSE)



