# Daily Plot of CAC-40 closing values for trading days (misses holidays, weekends, etc.)

# RStudio -> Session -> Set working directory -> To source file location
# RStudio Api set path
current_path = rstudioapi::getActiveDocumentContext()$path 
setwd(dirname(current_path))

cac40_idx = read.csv(
  'data/cac-40-index-france-historical-chart-data.csv', 
  skip = 13, 
  stringsAsFactors = TRUE)

# Check data
head(cac40_idx, 5)
tail(cac40_idx, 5)

# Plot CAC-40
plot(x = cac40_idx$date,
     y = cac40_idx$value,
     xlab = "date",
     ylab = "value",
     main = "CAC-40 plot"
)
