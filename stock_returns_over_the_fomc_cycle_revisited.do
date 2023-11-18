clear
version 11
set more off
set cformat %5.3f
capture log close
set scheme FOMC

cd "<insert-working-directory-here>"

cap mkdir stata_log
log using "stata_log/stata_log", replace

// Import data
import delimited "FOMC_dummy_generation/fomc_week_dummies_1994_nov2023.csv", clear
sort date
save d:fomc_data, replace

import delimited "F-F_Factors_daily_US/us_returns_df_1994_oct2023.csv", clear
sort date
save d:us_returns_data, replace

// Data Preprocessing
merge date using d:fomc_data d:us_returns_data
save d:fed_put_datamerged_data, replace
gen date2 = date(date, "YMD")

// Calculation of stock excess returns as in Cieslak et al. (2019)
ge m = (mktrf + rf) / 100 + 1
ge r = rf / 100 + 1
replace m = 1 if m ==. 
replace r = 1 if r ==. 
ge lnm = ln(m)
ge lnr = ln(r)

label variable m "1+stock return"
label variable r "1+bill return"
label variable lnm "ln(1+stock return)"
label variable lnr "ln(1+bill return)"

ge ex1 = 100 * (m - r)
ge ex5 = 100 * (m * m[_n+1] * m[_n+2] * m[_n+3] * m[_n+4] - r * r[_n+1] * r[_n+2] * r[_n+3] * r[_n+4])
label variable ex1 "1-day excess return, day t, pct"
label variable ex5 "5-day excess return, day t to t+4 pct"

ge t = _n
label variable t "Observation number"


// Stock Returns over the FOMC Cycle Replication results
// Replication of TABLE 1 PANEL A Column 1 (2013 to 2016) as in Cieslak et al. (2019)
eststo mlr1: reg ex1 w_t0 w_t2t4t6 if t >= 5307 & t <= 6089, robust

// Replication of TABLE 1 PANEL B Column 1 (1994 to 2013) as in Cieslak et al. (2019)
eststo mlr2: reg ex1 w_t0 w_t2t4t6 if t >= 16 & t < 5307, robust

// Replication of TABLE 1 PANEL A Column 1 (1994 to 2016) as in Cieslak et al. (2019)
eststo mlr3: reg ex1 w_t0 w_t2t4t6 if t >= 16 & t <= 6089, robust


esttab mlr1 mlr2 mlr3 using "stata_out/Stock Returns over the FOMC cycle.tex", ///
	r2(%9.4g) ar2(%9.4g) stats(N) starlevel(* 0.1 ** 0.05 *** 0.01) noobs ///
	mlabels("2014-2016" "1994-2014" "1994-2016") ///
	postfoot("significant at 1\%-level (***), 5\% level (**), 10\% level (*)")

	
// Stock Returns over the FOMC Cycle Revisited - MEA	
eststo mlr1: reg ex1 w_t0 w_t2t4t6 if t >= 6089 & t < 6872, robust // 2016-2019 sample
eststo mlr2: reg ex1 w_t0 w_t2t4t6 if t >= 6872 & t < 7658, robust // 2019-2022 covid sample
eststo mlr3: reg ex1 w_t0 w_t2t4t6 if t >= 6089, robust // 2016-2023 revisited sample
eststo mlr4: reg ex1 w_t0 w_t2t4t6, robust // 1994-2023

esttab mlr1 mlr2 mlr3 mlr4 using "stata_out/Stock Returns over the FOMC cycle Revisited.tex", ///
	r2(%9.4g) ar2(%9.4g) stats(N) starlevel(* 0.1 ** 0.05 *** 0.01) noobs ///
	mlabels("2016-2019" "2019-2022" "2016-2023" "1994-2023") ///
	postfoot("significant at 1\%-level (***), 5\% level (**), 10\% level (*)")


