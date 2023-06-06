# File: empirical_evidence_fed_put.R
# Title: Empirical Evidence of the FED Put

# Stock Returns over the FOMC Cycle
# Anna Cieslak, Duke University and CEPR
# Adair Morse, University of California Berkeley and NBER
# Annette Vissing-Jorgensen, University of California Berkeley and NBER

# Abstract: "We document that since 1994 the equity premium realized in the US and worldwide is
# earned entirely in weeks 0, 2, 4 and 6 in FOMC cycle time, i.e. in even weeks starting from the
# last FOMC meeting. We tie this fact causally to the Fed by studying intermeeting target changes,
# Fed funds futures, and internal meetings of the Board of Governors. The Fed has affected the stock
# market via unexpectedly accommodating policy, leading to large reductions in the equity risk
# premium. Evidence suggests systematic informal communication of Fed officials with the media
# and financial sector as a possible channel through which news about monetary policy has reached
# the market."

# The Economics of the Fed Put 
# Anna Cieslak, Fuqua School of Business, Duke University, NBER and CEPR
# Annette Vissing-Jorgensen, Haas School of Business, University of California, Berkeley, NBER

# "Since the mid-1990s, negative stock returns comove with downgrades to the Fed’s growth expectations 
# and predict policy accommodations. Textual analysis of FOMC documents reveals that policy makers pay 
# attention to the stock market. The primary mechanism is their concern with the consumption wealth effect, 
# with a secondary role for the market predicting the economy. We find little evidence of the Fed overreacting 
# to the market in an ex post sense (reacting beyond the market’s effect on growth expectations). 
# Although policy makers are aware that the Fed put could induce risk-taking, moral hazard considerations appear 
# not to significantly affect their decision-making ex ante." (JEL E44, E52, E58)

# Research Question: Does the "Fed Put" persist in the U.S. after the great financial crisis?

# Dates of FOMC meetings.
# => The FOMC meets eight times per year. ~ every 6.5 weeks 
# => Find empirical evidence that the excess profits are earned in 0, 2, 4 and 6 in FOMC cycle time.

# => Therefore, Build a time series with the historical FOMC dates?
# Sources:
# https://www.thebalancemoney.com/fomc-meetings-schedule-and-statement-summaries-3305975#toc-2017-fomc-meetings
# https://www.federalreserve.gov/monetarypolicy/fomccalendars.htm


# => Two different regressions to be performed: (Coefficients statistically significant and statistically different from each other?)
# Even weeks Vs. Odd weeks in FOMC cycle time starting from the last FOMC meeting.

# approx. Dates of the GFC? Which timespan for the GFC uses macrotrends.net in their plots?
# 3.1 Empirical Evidence of the FED Put before the GFC

# => Find the historical Dates of FOMC meetings before the GFC
# => Perform two regression using sp500 even weeks vs odd weeks within FOMC cycle times
# => Thinking: maybe could be modeled using a dummy variable and performing a CHOW Test?
# => Find out how to do this in R compared to STATA.


# 3.2 Empirical Evidence of the FED Put after the GFC
# 3.2.1 Does the "FED" Put exist after the GFC (should not be possible, no arbitrage!)


# Simple linear regression model between FFR and s&p500
# Fed Target Fund Rate
ffr <- read.csv('data/FEDFUNDS.csv')
# plot
plot(x = as.Date(ffr$DATE),
     y = ffr$FEDFUNDS,
     type = "l",
     lwd = 2,
     xlab = "date",
     ylab = "rate",
     main = "Federal Funds Effective Rate")
# Add a black horizontal line
abline(h = 0, col = "red")


# Empirical Evidence for the FED Put after the GFC (2018 till march 2023) using the S&P500 und FOMC cycle time binary dummies:


# 6th June 2023 - draft/proposed of the first regression model (empirical evidence of the FED Put):
# regress: 
# ŷ *sp500_t = γ0 *w_t-0 + ... + γ7 *w_t-7 + ε_t
# where:
# sp500_t ... Time series of the s&p500
# w_t-0 - w_t-7 ... Ex-ante / t-x ... x=[0,1,2,3,4,5,6,7] shifted binary dummies for odd/even weeks in the FOMC cycle
# ε_t ... Error term



# Empirical Evidence for the FED Put using the S&P500 and the FED target fund rate (before/after the GFC)





# Empirical Evidence for the FED Put using the S&P500 and the US shadow short rate (before/after the GFC)

