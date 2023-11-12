clear
version 11
set more off
set cformat %5.3f
capture log close
set scheme FOMC

cd "/Users/felixreichel/Documents/UNI/WIWI_Bachelor/2023S/SE Bachelorarbeit/ecb-monetary-policy-decisions-and-eurozone-stock-excess-returns"

cap mkdir stata_log
log using "stata_log/stata_log", replace

// Function to reload data and calculate stock excess returns
program define reload_data
    import delimited "FOMC_dummy_generation/fomc_week_dummies_1994_nov2023.csv", clear
    sort date
    save d:fomc_data, replace

    import delimited "US_Returns_Fama_French_Factors_daily/us_returns_df_1994_oct2023.csv", clear
    sort date
    save d:us_returns_data, replace

    merge date using d:fomc_data d:us_returns_data
    save d:fed_put_datamerged_data, replace
    gen date2 = date(date, "YMD")
	
	// calculate stock excess returns
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
end

// Reload data definitions and processing
reload_data


// Function to generate graphs
program define generate_graphs
    set scheme FOMC // set scheme for graphs

    keep if t >= 16 & t <= 6089
    egen avgex5 = mean(ex5), by(fomc_d)
    label variable avgex5 "Avg. 5-day stock minus T-bill return, t to t+4 (pct)"

    so fomc_d
    scatter avgex5 fomc_d if fomc_d <= 33, c(l l l) mlabel(fomc_d) yla(-0.2(0.2).6) graphregion(color(white)) name(fig1, replace)
    graph export fig1.pdf, replace
end

// Regression Model 1
program define regression_model_1
    reg ex1 w_t0 w_t2t4t6 if t >= 5307 & t <= 6089, robust
	
	// TODO: Fix Current Bug with the FOMC dummies in the sample
	//edit if !e(sample)
	replace fomc_d = 29 in 5746
	replace w_t0 = 0 in 5746

	replace w_t2t4t6 = 1 in 5746
	replace w_even = 1 in 5746

	replace w_t1 = 0 in 5746
	replace w_t2 = 0 in 5746
	replace w_t3 = 0 in 5746
	replace w_t4 = 0 in 5746
	replace w_t5 = 0 in 5746
	replace w_t6 = 1 in 5746
	replace w_tm1 = 0 in 5746
end

// Regression Model 2
program define regression_model_2
    reg ex1 w_t0 w_t2t4t6 if t >= 16 & t < 5307, robust
    // "TABLE 1 PANEL B Column 1" (1994 to 2013) as in Cieslak et al. (2019)
    // TODO: Fix Current Bugs with the FOMC dummies in the sample
end

// Regression Model 3
program define regression_model_3
    reg ex1 w_t0 w_t2t4t6 if t >= 16 & t <= 6089, robust
    // "TABLE 1 PANEL A Column 1" Main sample (1994-2016) as in Cieslak et al. (2019)
    // TODO: Fix Current Bugs with the FOMC dummies in the sample
end

// Own 
// Pre COVID-19 sample from 2016 to 2019
program define regression_model_pre_covid
    reg ex1 w_t0 w_t2t4t6 if t >= 6089 & t < 6872, robust
end

// Post COVID-19 sample from 2019 to 2022
program define regression_model_post_covid
    reg ex1 w_t0 w_t2t4t6 if t >= 6872 & t < 7658, robust
end


// Control: Full extension sample from 2016 to Nov 2023
program define regression_model_full
    reg ex1 w_t0 w_t2t4t6 if t >= 6089, robust
end


program define fomc_cycle_returns

	eststo mlr1: reg ex1 w_t0 w_t2t4t6 if t >= 5307 & t <= 6089, robust
	eststo mlr2: reg ex1 w_t0 w_t2t4t6 if t >= 16 & t < 5307, robust
    eststo mlr3: reg ex1 w_t0 w_t2t4t6 if t >= 16 & t <= 6089, robust
	
	esttab mlr1 mlr2 mlr3 using "Stock Returns over the FOMC cycle.tex", ///
		r2(%9.4g) ar2(%9.4g) stats(N) starlevel(* 0.1 ** 0.05 *** 0.01) noobs ///
		mlabels("2014-2016 sample" "1994-2014 sample" "1994-2016 sample") ///
		postfoot("significant at 1%-level (***), 5% level (**), 10% level (*)")
end

program define fomc_cycle_returns_revisited
	eststo mlr1: reg ex1 w_t0 w_t2t4t6 if t >= 6089 & t < 6872, robust // pre covid sample
	eststo mlr2: reg ex1 w_t0 w_t2t4t6 if t >= 6872 & t < 7658, robust // post covid sample
	eststo mlr3: reg ex1 w_t0 w_t2t4t6 if t >= 6089, robust // full revisited sample
	eststo mlr4: reg ex1 w_t0 w_t2t4t6, robust // full 

	esttab mlr1 mlr2 mlr3 mlr4 using "Stock Returns over the FOMC cycle Revisited.tex", ///
		r2(%9.4g) ar2(%9.4g) stats(N) starlevel(* 0.1 ** 0.05 *** 0.01) noobs ///
		mlabels("2016-2019" "2019-2022" "2016-2023" "1994-2023") ///
		postfoot("significant at 1%-level (***), 5% level (**), 10% level (*)")
end



// Execute Regression Models and Graphs

regression_model_1	// Run 2x
fomc_cycle_returns
fomc_cycle_returns_revisited

//generate_graphs
