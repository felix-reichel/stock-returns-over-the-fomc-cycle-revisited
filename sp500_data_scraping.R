install.packages("pacman")
install.packages("tidyquant")
library(pacman)
library(tidyquant)
p_load(tidyquant)

tq_index("SP500") # ^GSPC
# sp500_ticker <- '^GSPC'
# tq_get(sp500_ticker, get, from = "1995-01-01")
# Could not establish session after 5 attempts.


require(quantmod)

getSymbols.google(c("^GSPC"), auto.assign = TRUE, from = "1995-01-01")
# Error: ‘getSymbols.google’ is defunct.
# Google Finance stopped providing data in March, 2018.

getSymbols.yahoo(c("SP500"), auto.assign = TRUE, from = "1995-01-01")
getSymbols.yahoo(c("SP500"), auto.assign = TRUE, from = "1995-01-01", env = globalenv())
# Error in new.session() : Could not establish session after 5 attempts.

getSymbols.FRED(c("SP500"), auto.assign = TRUE, from = "1995-01-01", env = globalenv())
plot(SP500) # xts object with last 10 years of s&p 500
