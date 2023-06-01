# Daily Plot of Euro-area SSR (Shadow short rate)
install.packages('readxl')
library(readxl)

# RStudio -> Session -> Set working directory -> To source file location
# RStudio Api set path
current_path = rstudioapi::getActiveDocumentContext()$path 
setwd(dirname(current_path))

# Read in latest shadow short rate estimates
# Jfyi: data already contains weekends & holidays
daily_ssr_estimates <- read_excel(
  'data/SSR_Estimates_20230327.xlsx', 
  sheet = 4, 
  skip = 19)

# Check data
head(daily_ssr_estimates$`Euro-area SSR`, 3)
tail(daily_ssr_estimates$`Euro-area SSR`, 3)

POSIXct <- daily_ssr_estimates$...2
eu_ssr <- daily_ssr_estimates$`Euro-area SSR`

# Plot Euro-area SSR
plot(x = POSIXct,
     y = eu_ssr,
     type = "l",
     lwd = 2,
     xlab = "date",
     ylab = "shadow short rate",
     main = "Euro-area SSR")
abline(h = 0, col="blue")


