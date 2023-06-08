clear // empty working space
version 11 // version control
set more off // tells Stata not to pause or display the --more-- message
set cformat %5.3f // specifies the output format of coeff., s.e.,... in tables
capture log close // close any open log-file
set scheme s1mono // set scheme for graphs

/******************************************************************************

	Empirical Evidence of the FED Put - Multiple linear regression models

	Author: Felix Reichel
	
******************************************************************************/

// Set working directory 
cd "/Users/felixreichel/Documents/UNI/WIWI_Bachelor/2023S/SE Bachelorarbeit/Git"

cap mkdir stata_fed_put // generate a sub-folder "stata"

// Open log file
log using "stata_fed_put/stata_fed_put", replace

// Load FOMC cycle dummies .csv
import delimited "data/fomc_week_dummies.csv", clear
// Order master data by date
sort date
// save .dta
save d:fomc_data, replace

// Load SP500 data .csv
import delimited "data/sp500_df.csv", clear
// Order data by date
sort date
// save .dta
save d:sp500_data, replace

// Load US SSR data .csv
import delimited "data/us_ssr_df.csv", clear
// Order data by date
sort date
// save .dta
save d:us_ssr_data, replace

// Merge 1:1 Using date
merge date using d:fomc_data d:sp500_data d:us_ssr_data
// Save new merged data .dta
save d:fed_put_datamerged_data, replace

// Generate date2
gen date2 = date(date, "YMD")

// Drop rows with missing S&P500 values (holidays, weekends)
drop if missing(sp500_d1)

// Generate even/odd FOMC dummies
gen even_fomc_week = 0
replace even_fomc_week = 1 if fomc_w_floor == 0 | fomc_w_floor == 2 | fomc_w_floor == 4 | fomc_w_floor == 6

gen odd_fomc_week = 0
replace odd_fomc_week = 1 if fomc_w_floor == 1 | fomc_w_floor == 3 | fomc_w_floor == 5 | fomc_w_floor == 7


// Regression Models
// MLR with sp500 and 7 binary dummies for the fomc cycle time
reg sp500 w_t0 w_t1 w_t2 w_t3 w_t4 w_t5 w_t6 // R^2 of only 0.0118
reg sp500 us_ssr 							 //  R^2 = 0.0330

// MLR with sp500 process of differences of order 1 lag 1 and 7 binary dummies for the fomc cycle time
reg sp500_d1 w_t0 w_t1 w_t2 w_t3 w_t4 w_t5 w_t6

// MLR with sp500 process of differences of order 2 lag 1 and 7 binary dummies for the fomc cycle time
reg sp500_d2_test w_t0 w_t1 w_t2 w_t3 w_t4 w_t5 w_t6

// MLR with Log-Level regression model
gen lsp500 = log(sp500)

reg lsp500 w_t0 w_t1 w_t2 w_t3 w_t4 w_t5 w_t6 		 // R^2 = 0.0125
reg lsp500 us_ssr 							  		 // R^2 = 0.0347
reg lsp500 us_ssr w_t0 w_t1 w_t2 w_t3 w_t4 w_t5 w_t6 // R^2 = 0.0478

reg sp500 date2 us_ssr w_t0 w_t1 w_t2 w_t3 w_t4 w_t5 w_t6 // R^2 = 0.7879
reg lsp500 date2 us_ssr w_t0 w_t1 w_t2 w_t3 w_t4 w_t5 w_t6 // R^2 = 0.8153

reg lsp500 us_ssr fomc_w_plus 			// R^2=0.0391
reg lsp500 date2 us_ssr fomc_w_floor 	// R^2 = 0.8145
reg lsp500 date2 us_ssr fomc_w_plus 	// R^2 = 0.8145

reg lsp500 date2 i.even_fomc_week i.odd_fomc_week
reg lsp500 date2 us_ssr i.even_fomc_week i.odd_fomc_week

reg lsp500 date2 us_ssr i.even_fomc_week
reg lsp500 date2 us_ssr i.odd_fomc_week

// Pooled vs. separate estimation
qui reg lsp500 date2 us_ssr if even_fomc_week == 1, robust
scalar define SSRm = e(rss) // SSR for in even FOMC weeks
qui reg lsp500 date2 us_ssr if even_fomc_week == 0, robust
scalar def SSRf = e(rss) // SSR for in odd FOMC weeks
scalar def k = e(df_m) // k parameters
qui reg lsp500 date2 us_ssr if !missing(even_fomc_week), robust
scalar def SSRp = e(rss) // SSR pooled
qui count if e(sample)
scalar def n = r(N) // n observations
scalar list

// Compute the Chow test statistic (= F statistic):
scalar def fstat=((SSRp-(SSRm+SSRf))/(SSRm+SSRf))*(n-2*(k+1))/(k+1)
di "F = " %9.3f fstat
di "critical value =" %9.3f invFtail(k+1,n-2*(k+1),0.05)
di "p-value =" %9.3f Ftail(k+1,n-2*(k+1),fstat)
// p-value = 0.093 > 0.05
// => Therefore H0 can NOT be rejected, meaning a pooled regression model 
// fits the data better than two seperate regression models for odd/even weeks within the FOMC cycle.


// Chow test on some other regression models
// Pooled vs. separate estimation
qui reg lsp500 us_ssr if even_fomc_week == 1, robust
scalar define SSRm = e(rss) // SSR for in even FOMC weeks
qui reg lsp500 us_ssr if even_fomc_week == 0, robust
scalar def SSRf = e(rss) // SSR for in odd FOMC weeks
scalar def k = e(df_m) // k parameters
qui reg lsp500 us_ssr if !missing(even_fomc_week), robust
scalar def SSRp = e(rss) // SSR pooled
qui count if e(sample)
scalar def n = r(N) // n observations
scalar list

// Compute the Chow test statistic (= F statistic):
scalar def fstat=((SSRp-(SSRm+SSRf))/(SSRm+SSRf))*(n-2*(k+1))/(k+1)
di "F = " %9.3f fstat
di "critical value =" %9.3f invFtail(k+1,n-2*(k+1),0.05)
di "p-value =" %9.3f Ftail(k+1,n-2*(k+1),fstat)
// p-value = 0.573 > 0.05

// Pooled vs. separate estimation
qui reg lsp500 date2 if even_fomc_week == 1, robust
scalar define SSRm = e(rss) // SSR for in even FOMC weeks
qui reg lsp500 date2 if even_fomc_week == 0, robust
scalar def SSRf = e(rss) // SSR for in odd FOMC weeks
scalar def k = e(df_m) // k parameters
qui reg lsp500 date2 if !missing(even_fomc_week), robust
scalar def SSRp = e(rss) // SSR pooled
qui count if e(sample)
scalar def n = r(N) // n observations
scalar list

// Compute the Chow test statistic (= F statistic):
scalar def fstat=((SSRp-(SSRm+SSRf))/(SSRm+SSRf))*(n-2*(k+1))/(k+1)
di "F = " %9.3f fstat
di "critical value =" %9.3f invFtail(k+1,n-2*(k+1),0.05)
di "p-value =" %9.3f Ftail(k+1,n-2*(k+1),fstat)
// p-value = 0.288 > 0.05



cap log close
clear
