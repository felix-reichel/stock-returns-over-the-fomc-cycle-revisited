# File: empirical_evidence_ecb_put.R
# Title: Empirical Evidence of for an equivalent of the "Fed Put" in the Euro area

install.packages('readxl')
library(readxl)

# RStudio -> Session -> Set working directory -> To source file location
# RStudio Api set path
current_path = rstudioapi::getActiveDocumentContext()$path 
setwd(dirname(current_path))

# Read in latest shadow short rate estimates
# Jfyi: Data already contains weekends & holidays
# Timezone: UTC

daily_ssr_estimates <- read_excel('data/SSR_Estimates_20230327.xlsx', 
  sheet = 4, 
  skip = 19)

# Check data
head(daily_ssr_estimates$`Euro-area SSR`, 1)
tail(daily_ssr_estimates$`Euro-area SSR`, 1)

POSIXct <- daily_ssr_estimates$...2               # [1]="1995-01-03", [10311]="2023-03-27"
eu_ssr <- daily_ssr_estimates$`Euro-area SSR`

# Compare with a common euro stock index (e.g. CAC-40)
cac40_idx = read.csv('data/cac-40-index-france-historical-chart-data.csv', 
  skip = 13, 
  stringsAsFactors = TRUE)

# Check CAC-40 data
head(cac40_idx$date, 1) # 1990-03-01 UTC
tail(cac40_idx$date, 1) # 2023-03-13 UTC

# Generate a data frame with matching data points (misses holidays, weekends, etc.)
# Find matching interval x[x1:x2]
cac40_x1 <- as.Date(cac40_idx$date[1])
cac40_x2 <- as.Date(cac40_idx$date[length(cac40_idx$date)])

eu_ssr_x1 <- as.Date(daily_ssr_estimates$...2[1])
eu_ssr_x2 <- as.Date(daily_ssr_estimates$...2[length(daily_ssr_estimates$...2)])

x1 <- max(cac40_x1, eu_ssr_x1)
x2 <- min(cac40_x2, eu_ssr_x2)

# Generate a sequence for matching interval x[x1:x2]
cac40_x <- as.Date(cac40_idx$date)
x <- Filter(function(x) x >= x1 & x <= x2, cac40_x)  # misses holidays, weekends, etc.

  # For an alternative (interpolated) approach
  # x_seq <- seq(x1_date, x2_date, by="days")          # contains holidays, weekends, etc.

  # Create empty vectors for y1, y2
  # eu_ssr_y1_vec <- c()
  # cac40_y2_vec <- c()

# Check types of data frames
class(daily_ssr_estimates) # [1] "tbl_df"     "tbl"        "data.frame"
class(cac40_idx)           # [1] "data.frame"

# Select rows based on column condition %in% x
y1_df <- daily_ssr_estimates[as.Date(daily_ssr_estimates$...2) %in% x, ]
y2_df <- cac40_idx[as.Date(cac40_idx$date) %in% x, ]

# Construct new data frame
y1 <- y1_df$`Euro-area SSR`
y2 <- y2_df$value
df <- data.frame(
      Date = x,
      EuroSSR = y1,
      CAC40idx = y2
    )

# Test plots for Euro-SSR, CAC-40
plot(x = df$Date,
     y = df$EuroSSR,
     type = "l",
     lwd = 2,
     xlab = "date",
     ylab = "shadow short rate",
     main = "Euro-area SSR")
abline(h = 0, col="blue")

plot(x = df$Date,
     y = df$CAC40idx,
     type = "l",
     lwd = 2,
     xlab = "date",
     ylab = "points",
     main = "CAC-40")


# TODO: Compare differences/sign of deltas

  # prevDate <- df$Date[1] # first date
  # diff1
  # for (date in df$Date) {
  #  if ()
  # }

# TODO: Time series econometrics

require(astsa) 
require(tseries)

freq <- 1
ts_eurossr <- ts(data = eu_ssr, start = x1, end = x2, frequency = freq) 
plot(ts_eurossr)
abline(h = 0, col="blue")

# Augmented Dickey-Fuller and Kwiatkowski–Phillips–Schmidt–Shin (KPSS) tests for time series

# d0
adf.test(ts_eurossr)                  # p-value = 0.9694 > 0.05 => H1 => No Stationary
kpss.test(ts_eurossr, null= "Level")  # p-value = 0.01 < 0.05 => H1 => No Level Stationarity 
kpss.test(ts_eurossr, null = "Trend") # p-value = 0.01 < 0.05 => H1 => No Trend Stationarity 

# d1
d1 <- diff(ts_eurossr, lag = freq)
plot(d1) 
adf.test(d1)                  # p-value = 0.01 < 0.05 => H1 => Stationary
kpss.test(d1, null= "Level")  # p-value = 0.01 < 0.05 => H1 => No Level Stationarity 
kpss.test(d1, null = "Trend") # p-value = 0.01 < 0.05 => H1 => No Trend Stationarity 

# d2
d2 <- diff(d1)                
plot(d2)
adf.test(d2)                  # p-value = 0.01 < 0.05 => H1 => Stationary
kpss.test(d2, null= "Level")  # p-value = 0.1 > 0.05 => H1 => Level Stationarity 
kpss.test(d2, null = "Trend") # p-value = 0.1 > 0.05 => H1 => Trend Stationarity 


# Research Question: Is there empirical evidence for an equivalent of the "Fed Put" in the Euro area?

# Read ECB Main Refinancing Operations Rate
ecbmrrfr <- read.csv('data/ECBMRRFR_(ECB_Main_Refinancing_Operations_Rate).csv')
ecbmrrfr <- ecbmrrfr[ecbmrrfr$ECBMRRFR != '.', ]  

