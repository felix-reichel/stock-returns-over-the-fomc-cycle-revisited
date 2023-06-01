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

ecbmrrfr <- read.csv('data/ECBMRRFR_(ECB_Main_Refinancing_Operations_Rate).csv')
ecbmrrfr <- ecbmrrfr[ecbmrrfr$ECBMRRFR != '.', ]  

ecb_pir <- read.csv(
  'ECBDFR_(ECB_Deposit_Facility_Rate.csv', 
  stringsAsFactors = TRUE)

# Plot Euro-area SSR
plot(x = as.Date(daily_ssr_estimates$...2),
     y = daily_ssr_estimates$`Euro-area SSR`,
     type = "l",
     lwd = 2,
     xlab = "date",
     ylab = "shadow short rate",
     main = "Euro-area SSR (black), ECBDFR (blue), ECBMRRFR (red)")

# Add a black horizontal line
abline(h = 0, col = "black")

# Add a blue line for ECB Deposit Facility Rate.csv
lines(as.Date(ecb_pir$DATE), 
      ecb_pir$ECBDFR, 
      col = "blue",
      lwd = 2)

# Add a red line for ECB Main Refinancing Operations Rate 
lines(as.Date(ecbmrrfr$DATE), 
      ecbmrrfr$ECBMRRFR,
      col = "red",
      lwd = 2)
