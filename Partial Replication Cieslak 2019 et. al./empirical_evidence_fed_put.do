clear // empty working space
version 11 // version control
set more off // tells Stata not to pause or display the --more-- message
set cformat %5.3f // specifies the output format of coeff., s.e.,... in tables
capture log close // close any open log-file
set scheme s1mono // set scheme for graphs

/******************************************************************************

	Partial Replication "Stock Returns over the FOMC Cycle" Cieslak et al. (2019) 
		
	
	Author: Felix Reichel
	- From 2014 till 2016 -

	
	Cieslak et al. (2019) 
	"
		VI. Conclusion 
		In this paper, we have documented a novel pattern in stock returns in the United States and around the world. Over the last 23 years, 
		the equity premium has been earned entirely in even weeks in FOMC cycle time. This pattern is statistically robust and continues
		to be present over the 2014 to 2016 period following the first draft of our paper.
		
		The FOMC calendar is irregular across years and does not appear to line up with calendars for reserve maintenance periods, 
		macro releases or corporate earnings releases. Four pieces of evidence make it likely that the FOMC cycle in stock returns 
		is driven by monetary policy news from the Fed. 
		
		Intermeeting target changes tend to be in even weeks, Fed funds futures yields on average fell in even weeks, 
		high even-week stock returns are disproportionately driven by even-week days with Board of Governors board meetings,
		and even-week returns are particularly high following poor stock market performance, 
		con- sistent with a Fed put.
		
		A central mechanism through which the Fed appears to move the market is by reducing the equity premium,
		with this mechanism particularly important for explaining the Fed put.
		
		To establish the channel for how information gets from the Fed to asset markets, we show that the biweekly peaks
		in average excess stock returns over the FOMC cycle do not systematically line up with official public releases or speeches by Fed officials.
		
		Instead, we argue based on both documented leaks and narrative evidence (including the FOMC’s own deliberations about leaks) that 
		the Fed systematically uses informal communication channels. We lay out motives for the Fed’s systematic informal communication 
		emphasizing flexibility, explaining policy, learning from the market, and disagreement among Fed officials. 
		
		Only learning from the private financial sector could have bene- fits from a public policy perspective, 
		but any such benefits must be balanced against the risk of insider trading and informal communication undermining 
		the public’s trust in financial markets and the Fed.
		
		Initial submission: June 13, 2016; Accepted: May 9, 2018 Editors: Stefan Nagel, Philip Bond, Amit Seru, and Wei Xiong
	"
	

	
******************************************************************************/

// Set working directory 
cd "/Users/felixreichel/Documents/UNI/WIWI_Bachelor/2023S/SE Bachelorarbeit/Git/Partial Replication Cieslak 2019 et. al."

cap mkdir stata_fed_put // generate a sub-folder "stata"

// Open log file
log using "stata_fed_put/stata_fed_put", replace

// Load FOMC cycle dummies .csv
import delimited "fomc_week_dummies_2014_2016.csv", clear
// Order master data by date
sort date
// save .dta
save d:fomc_data, replace

// Load SP500 data .csv
import delimited "sp500_df_2014_2016.csv", clear
// Order data by date
sort date
// save .dta
save d:sp500_data, replace

// Load US SSR data .csv
// import delimited "data/us_ssr_df.csv", clear
// Order data by date
// sort date
// save .dta
// save d:us_ssr_data, replace

// Merge 1:1 Using date
// merge date using d:fomc_data d:sp500_data d:us_ssr_data
merge date using d:fomc_data d:sp500_data
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



// MLR with Log-Level regression model
gen lsp500 = log(sp500)
reg lsp500 date2 w_t0 w_t1 w_t2 w_t3 w_t4 w_t5 w_t6

reg lsp500 date2 i.even_fomc_week
reg lsp500 date2 i.odd_fomc_week

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
// p-value = 0.970 > 0.05
// => Therefore H0 can NOT be rejected, meaning a pooled regression model 
// fits the data better than two seperate regression models for odd/even weeks within the FOMC cycle.

cap log close
clear
