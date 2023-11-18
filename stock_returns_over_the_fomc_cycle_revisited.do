// U.S. Stock Returns over the FOMC Cycle - Measurement and Estimation Analysis (MEA)
clear
set more off
set cformat %5.3f
capture log close
set scheme FOMC
cd "<insert-working-directory-here>"
cap mkdir stata_log
log using "stata_log/stata_log", replace

import delimited "FOMC_dummy_generation/fomc_week_dummies_1994_nov2023.csv", clear
sort date
save d:fomc_data, replace

import delimited "F-F_Factors_daily_US/us_returns_df_1994_oct2023.csv", clear
sort date
save d:us_returns_data, replace

merge date using d:fomc_data d:us_returns_data
save d:fed_put_datamerged_data, replace
gen date2 = date(date, "YMD")

gen m = (mktrf + rf) / 100 + 1
gen r = rf / 100 + 1
replace m = 1 if m ==. 
replace r = 1 if r ==. 
label var m "1+stock return"
label var r "1+bill return"
gen ex1 = 100 * (m - r)
label var ex1 "1-day excess return, day t, pct"
gen t = _n
label var t "Observation number"

eststo mlr1: reg ex1 w_t0 w_t2t4t6 if t >= 5307 & t <= 6089, robust
eststo mlr2: reg ex1 w_t0 w_t2t4t6 if t >= 16 & t < 5307, robust
eststo mlr3: reg ex1 w_t0 w_t2t4t6 if t >= 16 & t <= 6089, robust
esttab mlr1 mlr2 mlr3 using "stata_out/Stock Returns over the FOMC cycle.tex", ///
	r2(%9.4g) ar2(%9.4g) stats(N) starlevel(* 0.1 ** 0.05 *** 0.01) noobs ///
	mlabels("2014-2016" "1994-2014" "1994-2016") ///
	postfoot("significant at 1\%-level (***), 5\% level (**), 10\% level (*)")

eststo mlr1: reg ex1 w_t0 w_t2t4t6 if t >= 6089 & t < 6872, robust 
eststo mlr2: reg ex1 w_t0 w_t2t4t6 if t >= 6872 & t < 7658, robust 
eststo mlr3: reg ex1 w_t0 w_t2t4t6 if t >= 6089, robust 
eststo mlr4: reg ex1 w_t0 w_t2t4t6, robust // 1994-2023
esttab mlr1 mlr2 mlr3 mlr4 using "stata_out/Stock Returns over the FOMC cycle Revisited.tex", ///
	r2(%9.4g) ar2(%9.4g) stats(N) starlevel(* 0.1 ** 0.05 *** 0.01) noobs ///
	mlabels("2016-2019" "2019-2022" "2016-2023" "1994-2023") ///
	postfoot("significant at 1\%-level (***), 5\% level (**), 10\% level (*)")

// European Stock Returns over the FOMC Cycle - Measurement and Estimation Analysis (MEA)
clear
import delimited "FOMC_dummy_generation/fomc_week_dummies_1994_nov2023.csv", clear
sort date
save d:fomc_data, replace
	
import delimited "F-F_Factors_daily_European/european_returns_df_1994_sept2023.csv", clear
sort date
save d:eur_returns_data, replace

merge date using d:fomc_data d:eur_returns_data
save d:fomc_eur_ret_datamerged_data, replace
gen date2 = date(date, "YMD")

gen m = (mktrf + rf) / 100 + 1
gen r = rf / 100 + 1
replace m = 1 if m ==. 
replace r = 1 if r ==. 
label var m "1+stock return"
label var r "1+bill return"
gen ex1 = 100 * (m - r)
label var ex1 "1-day excess return, day t, pct"
gen t = _n
label var t "Observation number"

eststo mlr1: reg ex1 w_t0 w_t2t4t6 if t >= 5307 & t <= 6089, robust
eststo mlr2: reg ex1 w_t0 w_t2t4t6 if t >= 16 & t < 5307, robust
eststo mlr3: reg ex1 w_t0 w_t2t4t6 if t >= 16 & t <= 6089, robust
esttab mlr1 mlr2 mlr3 using "stata_out/European Returns over the FOMC cycle.tex", ///
	r2(%9.4g) ar2(%9.4g) stats(N) starlevel(* 0.1 ** 0.05 *** 0.01) noobs ///
	mlabels("2014-2016" "1994-2014" "1994-2016") ///
	postfoot("significant at 1\%-level (***), 5\% level (**), 10\% level (*)")

eststo mlr1: reg ex1 w_t0 w_t2t4t6 if t >= 6089 & t < 6872, robust 
eststo mlr2: reg ex1 w_t0 w_t2t4t6 if t >= 6872 & t < 7658, robust 
eststo mlr3: reg ex1 w_t0 w_t2t4t6 if t >= 6089, robust 
eststo mlr4: reg ex1 w_t0 w_t2t4t6, robust // 1994-2023
esttab mlr1 mlr2 mlr3 mlr4 using "stata_out/European Stock Returns over the FOMC cycle Revisited.tex", ///
	r2(%9.4g) ar2(%9.4g) stats(N) starlevel(* 0.1 ** 0.05 *** 0.01) noobs ///
	mlabels("2016-2019" "2019-2022" "2016-2023" "1994-2023") ///
	postfoot("significant at 1\%-level (***), 5\% level (**), 10\% level (*)")
