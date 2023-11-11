install.packages('readxl')
library(readxl)

# RStudio -> Session -> Set working directory -> To source file location
# RStudio Api set path
current_path = rstudioapi::getActiveDocumentContext()$path 
setwd(dirname(current_path))

# Read in latest shadow short rate estimates
daily_ssr_estimates <- read_excel(
  'data/SSR_Estimates_20230327.xlsx', 
  sheet = 4, 
  skip = 19)

ffr <- read.csv('data/FEDFUNDS.csv')

# Plot U.S. SSR
plot(x = as.Date(daily_ssr_estimates$...2),
     y = daily_ssr_estimates$`US SSR`,
     type = "l",
     lwd = 2,
     xlab = "date",
     ylab = "shadow short rate",
     main = "U.S. SSR (black), Federal Funds Effective Rate (blue)")

# Add a black horizontal line
abline(h = 0, col = "black")

# Add a blue line for FEDFUNDS
lines(as.Date(ffr$DATE), 
      ffr$FEDFUNDS, 
      col = "blue",
      lwd = 2)

# export ssr and fedfunds from 2018-01-30 to 2023-03-20 ideally 
# (should be possible, since SSR_Estimates_20230327)


export_start_date <- as.Date("2018-01-30")
export_end_date <- as.Date("2023-03-20")

require(astsa) 
require(tseries)


us_ssr_estimates <- daily_ssr_estimates$`US SSR`
us_ssr_dates <- as.Date(daily_ssr_estimates$...2)

ffr_dates <- as.Date(ffr$DATE)
ffr <- ffr$FEDFUNDS

us_ssr_idx1 <- which(us_ssr_dates == export_start_date)
us_ssr_idx2 <- which(us_ssr_dates == export_end_date)

# ffr_idx1 <- which(ffr_dates == export_start_date) -> todo find nearest value
# ffr_idx2 <- which(ffr_dates == export_end_date)   -> todo find nearest value

# data frame
us_ssr_df <- data.frame(
  date = us_ssr_dates[us_ssr_idx1:us_ssr_idx2],
  us_ssr = us_ssr_estimates[us_ssr_idx1:us_ssr_idx2]
)

# write .csv
write.csv(us_ssr_df, 'data/us_ssr_df.csv', row.names = FALSE)

