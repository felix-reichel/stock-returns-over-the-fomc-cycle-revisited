require(quantmod)
require(xts)

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

# Create data.frame
sp500_df <- data.frame(
  date = index(xts18mar23),
  sp500_y = as.numeric(xts18mar23)
)

# Write csv
write.csv(sp500_df, 'data/sp500_df.csv', row.names = FALSE)

