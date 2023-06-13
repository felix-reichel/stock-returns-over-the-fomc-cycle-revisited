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
//import delimited "fomc_week_dummies_2010_2016.csv", clear
import delimited "fomc_week_dummies_2014_2016.csv", clear
// Order master data by date
sort date
// save .dta
save d:fomc_data, replace


// Load SP500 data .csv
//import delimited "sp500_df_2014_2016.csv", clear
// Order data by date
//sort date
// save .dta
//save d:sp500_data, replace

// Load us_returns_df_2010_2016.csv
import delimited "us_returns_df_2010_2016.csv", clear
// Order data by date
sort date
// save .dta
save d:us_returns_data, replace

merge date using d:fomc_data d:us_returns_data d:sp500_data

// Save new merged data .dta
save d:fed_put_datamerged_data, replace

// Generate date2
gen date2 = date(date, "YMD")

// For 2014 to 2016

drop if date2 <= 19723

// Cieslak replication File excess returns

* Stock and bill return variables
* -------------------------------

//Expected Return = Risk-free rate + (Beta*Market risk premium)

//                             = Rf + β(Rm – Rf)


//Excess return = Total return – Expected return

//Applying the expected return formula to the above:

 //                      = Tr – Rf + β(Rm – Rf)


ge m=(mktrf+rf)/100+1
ge r=rf/100+1
replace m=1 if m==. 
replace r=1 if r==. 
ge lnm=ln(m)
ge lnr=ln(r)

label variable m "1+stock return"
label variable r "1+bill return"
label variable lnm "ln(1+stock return)"
label variable lnr "ln(1+bill return)"

//so year month day
ge ex1=100*(m-r)
ge ex5=100*(m*m[_n+1]*m[_n+2]*m[_n+3]*m[_n+4]-r*r[_n+1]*r[_n+2]*r[_n+3]*r[_n+4] )
label variable ex1 "1-day excess return, day t, pct"
label variable ex5 "5-day excess return, day t to t+4 pct"

ge t=_n
label variable t "Observation number"


// ------






drop if t > 783

// drop if missing(mktrf)


// 777 observations vs. 783 (6 diff) because of "drop for missing dummies" (-6 obs.)

lgraph ex5 fomc_d



// MLR





reg ex1 w_t0 w_t2t4t6


// edit if !e(sample)
replace fomc_d = 29 in 440
replace w_t0 = 0 in 440

replace w_t2t4t6 = 1 in 440
replace w_even = 1 in 440

replace w_t1 = 0 in 440
replace w_t2 = 0 in 440
replace w_t3 = 0 in 440
replace w_t4 = 0 in 440
replace w_t5 = 0 in 440
replace w_t6 = 1 in 440
replace w_tm1 = 0 in 440

reg ex1 w_t0 w_t2t4t6

reg ex1 w_tm1 w_t1 w_t3 w_t5

reg ex1 w_t0 w_t2 w_t4, robust

reg ex1 w_t0 w_t2t4t6, robust


cap log close
clear
