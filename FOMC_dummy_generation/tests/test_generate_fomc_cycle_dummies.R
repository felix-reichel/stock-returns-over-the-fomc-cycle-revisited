library(testthat)

test_that("get_fomc_day_within_fomc_cycle returns expected values", {
  
  fomc_test_date <- as.Date("2014-01-28")

  expected_values <- c(
    -5, -4, -3, -2, NULL, NULL, -1, 0, 1, 2, 3, 
    NULL, NULL, 4, 5, 6, 7, 8, NULL, NULL, 9, 10)

  dates <- as.Date(
    c("2014-01-21", "2014-01-22", "2014-01-23", "2014-01-24", 
      "2014-01-25", "2014-01-26", "2014-01-27", "2014-01-28",
      "2014-01-29", "2014-01-30", "2014-01-31", "2014-02-01", 
      "2014-02-02", "2014-02-03", "2014-02-04", "2014-02-05", 
      "2014-02-06", "2014-02-07", "2014-02-08", "2014-02-09",
      "2014-02-10", "2014-02-11"))
  
  for (i in dates) {
    expect_equal(get_fomc_day_within_fomc_cycle(fomc_test_date, dates[i]), expected_values[i])
  }
})
