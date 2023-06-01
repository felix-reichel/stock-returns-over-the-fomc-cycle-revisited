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
