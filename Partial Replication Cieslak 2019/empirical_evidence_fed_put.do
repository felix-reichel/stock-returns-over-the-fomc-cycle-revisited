clear
version 11
set more off
set cformat %5.3f
capture log close
set scheme s1mono

/****************************************************************************************************

	Partial Replication of results in "Stock Returns over the FOMC Cycle" in Cieslak et al. (2019) 
		
*****************************************************************************************************/

// Set wd
cd "/Users/felixreichel/Documents/UNI/WIWI_Bachelor/2023S/SE Bachelorarbeit/ecb-monetary-policy-decisions-and-eurozone-stock-excess-returns/Partial Replication Cieslak 2019"

cap mkdir stata_log

log using "stata_log/stata_log", replace

// Load FOMC cycle dummies .csv
import delimited "fomc_week_dummies_2014_2016.csv", clear

sort date
save d:fomc_data, replace

// Load us_returns_df_2010_2016.csv
import delimited "us_returns_df_2010_2016.csv", clear

sort date
save d:us_returns_data, replace

merge date using d:fomc_data d:us_returns_data

// Save new merged data .dta
save d:fed_put_datamerged_data, replace


gen date2 = date(date, "YMD")

// For 2014 to 2016
drop if date2 <= 19723

// Stock excess return calculations as in Cieslak et al. (2019)
ge m = (mktrf+rf)/100+1
ge r = rf/100+1
replace m = 1 if m ==. 
replace r = 1 if r ==. 
ge lnm = ln(m)
ge lnr = ln(r)

label variable m "1+stock return"
label variable r "1+bill return"
label variable lnm "ln(1+stock return)"
label variable lnr "ln(1+bill return)"

ge ex1=100*(m-r)
ge ex5=100*(m*m[_n+1]*m[_n+2]*m[_n+3]*m[_n+4]-r*r[_n+1]*r[_n+2]*r[_n+3]*r[_n+4] )
label variable ex1 "1-day excess return, day t, pct"
label variable ex5 "5-day excess return, day t to t+4 pct"

ge t=_n
label variable t "Observation number"

// ------
drop if t > 783

// MLR
reg ex1 w_t0 w_t2t4t6

// Unresolved problem with the data sample
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

reg ex1 w_tm1 w_t1 w_t3 w_t5
reg ex1 w_t0 w_t2t4t6

* Replicate of
* "TABLE 1 PANEL B Column 1" (2014-2016) as in Cieslak et al. (2019)
reg ex1 w_t0 w_t2t4t6, robust


set scheme FOMC // set scheme for graphs

egen avgex5 = mean(ex5), by(fomc_d)
label variable avgex5 "Avg. 5-day stock minus T-bill return, t to t+4 (pct)"

* Adaptation for (2014-2016) of
* "FIGURE 1"
* --------

lgraph ex5 fomc_d

so fomc_d
scatter avgex5 fomc_d if fomc_d<=33, c(l l l) mlabel(fomc_d) yla(-0.2(0.2).6) graphregion(color(white)) name(fig1,replace)
graph export fig1.pdf, replace

so fomc_d
scatter avgex5 fomc_d if fomc_d<=28, c(l l l) mlabel(fomc_d) yla(-0.2(0.2).6) graphregion(color(white))  name(fig1,replace)
graph export fig2.pdf, replace


