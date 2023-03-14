# RStudio -> Session -> Set working directory -> To source file location
cac40_idx = read.csv(
  'cac-40-index-france-historical-chart-data.csv', 
  skip = 13, 
  stringsAsFactors = TRUE)

# check data
head(cac40_idx, 5)
tail(cac40_idx, 5)

# plot CAC-40
plot(x = cac40_idx$date,
     y = cac40_idx$value,
     xlab = "date",
     ylab = "value",
     main = "CAC-40 plot"
)
