# Daily Plot of Euro-area SSR (Shadow short rate)
install.packages('readxl')
library(readxl)

# RStudio -> Session -> Set working directory -> To source file location

# Read in latest shadow short rate estimates
# jfyi: data already contains weekends & holidays
daily_ssr_estimates <- read_excel(
  'SSR_Estimates_20230327.xlsx', 
  sheet = 4, 
  skip = 19)

head(daily_ssr_estimates$`Euro-area SSR`, 3)
tail(daily_ssr_estimates$`Euro-area SSR`, 3)

POSIXct <- daily_ssr_estimates$...2
eu_ssr <- daily_ssr_estimates$`Euro-area SSR`

# test plot Euro-area SSR
plot(x = POSIXct,
     y = eu_ssr,
     xlab = "date",
     ylab = "value",
     main = "Euro-area SSR")

# simple TODO 1: make the plot nicer
# simple TODO 2: plot against stock (CAC-40, DAX) index plot


