
cd "/Users/felixreichel/Downloads/Replication Code"

set scheme FOMC, permanently

cap log close
local today = "`c(current_date)'"
log using "run_FOMC_`today'.log", text replace

set type double, permanently
drop _all
set more off

* ===========================
* DATA PROCESSING/DEFINITIONS
* ===========================

clear
use fomc_data_base
de, full
so year month day


* FOMC cycle variables
* --------------------

* Day in FOMC cycle

so year month day
ge cycle=0 if fomc==1
for num 1/60: replace cycle=X if cycle==. & fomc[_n-X]==1
for num 1/6: replace cycle=-X if fomc[_n+X]==1
label variable cycle "Days since FOMC meeting (weekends excluded)"

* Weeks of FOMC cycle

ge block=-1 if (cycle>=-6 & cycle<=-2)
replace block=0 if (cycle>=-1 & cycle<=3)
replace block=1 if (cycle>=4 & cycle<=8)
replace block=2 if (cycle>=9 & cycle<=13)
replace block=3 if (cycle>=14 & cycle<=18)
replace block=4 if (cycle>=19 & cycle<=23)
replace block=5 if (cycle>=24 & cycle<=28) 
replace block=6 if (cycle>=29 & cycle<=33) 
label variable block "Week in FOMC cycle time"

ge block0246=inlist(block,0,2,4,6)==1
ge block246=inlist(block,2,4,6)==1
for num 0 2 4 6: ge blockX=block==X
ge blockm1135=inlist(block,-1,1,3,5)

label variable block0246 "Dummy=1 in Week 0,2,4,6"
label variable block246 "Dummy=1 in Week 2,4,6"
for any 0 2 4 6: label variable blockX "Dummy=1 in Week X"
label variable blockm1135 "Dummy=1 in Week -1,1,3,5"

* 275 FOMC cycles from Sep 1982 to 2016

ge start=1 if cycle==-6
replace start=2 if start~=1
so start year month day
ge fomccycle=_n if start==1
drop start
so year month day
replace fomccycle=fomccycle[_n-1] if fomccycle==.
label variable fomccycle "FOMC cycle since Sep 1982 (275 cycles)"

* 1857 weeks in FOMC cycle time from Sep 1982 to 2016

so year month day
ge newblock=1 if block~=block[_n-1]
so newblock year month day
ge fomcblock=_n if newblock==1
so year month day
replace fomcblock=fomcblock[_n-1] if fomcblock==.
drop newblock
label variable fomcblock "FOMC week since Sep 1982 (1857 weeks)"


* Stock and bill return variables
* -------------------------------

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

so year month day
ge ex1=100*(m-r)
ge ex5=100*(m*m[_n+1]*m[_n+2]*m[_n+3]*m[_n+4]-r*r[_n+1]*r[_n+2]*r[_n+3]*r[_n+4] )
label variable ex1 "1-day excess return, day t, pct"
label variable ex5 "5-day excess return, day t to t+4 pct"

ge t=_n
label variable t "Observation number"

tsset t
for num 5 22 65: tssmooth ma smX=X*lnm, w(X)
for num 5 22 65: tssmooth ma srX=X*lnr, w(X)
for num 5 22 65: ge sX=exp(smX)-exp(srX)
for num 5 22 65: xtile xX=sX if cycle<=33 & year>=1994, nq(5)

ge panic1=x5==1
ge panic2=x5==1 & x22==1
ge panic3=x5==1 & x22==1 & x65==1
drop sm5-sr65 s22 s65 x22 x65

label variable s5 "5-day excess return, day t-5 to t-1"
label variable x5 "Quintiles of days based on last week's excess return"
label variable panic1 "Quintile 1 day, based on last week"
label variable panic2 "Quintile 1 day, based on last week and last month"
label variable panic3 "Quintile 1 day, based on last week, last month, and last 3 months"
 

* Futures
* -------

for num 1 2 23 24: replace ffX=ffX[_n-1] if ffX==. & month==month[_n-1]
for num 2 24: ge dffX=.
for num 2 24: replace dffX=ffX-ffX[_n-1] if month==month[_n-1]
for num 2 24: ge d5ffX=.
for num 2 24: replace d5ffX=ffX[_n+4]-ffX[_n-1] if month[_n+4]==month[_n-1]

replace dff2=ff1[_n]-ff2[_n-1] if month[_n]~=month[_n-1]
replace dff24=ff23[_n]-ff24[_n-1] if month[_n]~=month[_n-1]
replace d5ff2=ff1[_n+4]-ff2[_n-1] if month[_n+4]~=month[_n-1]
replace d5ff24=ff23[_n+4]-ff24[_n-1] if month[_n+4]~=month[_n-1]
label variable dff2 "1-day change in 2nd fed funds futures yield"
label variable dff24 "1-day change in 24th fed funds futures yield"
label variable d5ff2 "5-day change in 2nd fed funds futures yield"
label variable d5ff24 "5-day change in 24th fed funds futures yield"

so t

de, full

save fomc_data1, replace





* =================
* TABLE and FIGURES
* =================


* FIGURE 1
* --------

clear
use fomc_data1, replace
keep if year>=1994

egen avgex5=mean(ex5) if year>=1994, by(cycle)
label variable avgex5 "Avg. 5-day stock minus T-bill return, t to t+4 (pct)"
so cycle
scatter avgex5 cycle if cycle<=33, c(l l l) mlabel(cycle) yla(-0.2(0.2).6) graphregion(color(white))  name(fig1,replace)
graph export fig1.pdf, replace


* FIGURE 2
* --------

clear
use fomc_data1
keep if year>=1994
ge doy=doy(mdy(month,day,year))
label variable doy "Day of the year"
histogram doy if cycle==0, width(1) xla(0(30)366) start(0) freq graphregion(color(white))  name(fig2, replace)
graph export fig2.pdf, replace


* FIGURE 3
* --------

* PANEL A

clear
use fomc_data1
keep if year<1994
ge change5=fftarget[_n+4]~=fftarget[_n-1]
egen mchange5=mean(change5), by(cycle)
so cycle
label variable mchange5 "Prob. of FF target change over day t to t+4"
scatter mchange5 cycle if cycle<=33,  mlabel(cycle) c(l) graphregion(color(white)) ylabel(0(0.1)0.4)  name(fig3A,replace)
graph export fig3A.pdf, replace

* PANEL B

clear
use fomc_data1
ge datadrop=year==2008 & month>=9
ge f5=d5ff2 if year<=2008
replace f5=d5ff24 if year>=2009
egen mf5=mean(f5) if cycle<=33 & year>=2000 & datadrop==0, by(cycle)
label variable mf5 "Avg. 5-day yield changes from t-1 to t+4"
so cycle
scatter mf5 cycle if cycle<=33, c(l) mlabel(cycle) graphregion(color(white)) name(fig3B, replace)
graph export fig3B.pdf, replace

* PANEL C

clear
use fomc_data1
ge datadrop=year==2008 & month>=9
ge f=dff2 if year<=2008
replace f=dff24 if year>=2009
so block
//egen cf=corr(f ex1) if year>=2000 & datadrop==0, by(block) c 
//label variable cf "Covariance"
//label variable block "FOMC cycle week"
//scatter cf block if cycle<=33, c(l l l) mlabel(block) graphregion(color(white))   name(fig3C, replace)
//graph export fig3C.pdf, replace


* FIGURE 4
* --------

clear
use fomc_data1

keep if cycle<=33 & year>=1994
egen avg_r=mean(s5*100), by(x5)

* PANEL A

egen mxxe=mean(ex1) if block0246==1, by(x5)
egen mxxo=mean(ex1) if block0246==0, by(x5)
egen mmxxe=max(mxxe), by(x5)
egen mmxxo=max(mxxo), by(x5)

label variable mmxxe "Even weeks"
label variable mmxxo "Odd weeks"
label variable avg_r "Average 5-day excess returns, day t-5 to t-1"

so avg_r
scatter mmxxe mmxxo avg_r if mmxxe>-0.1 & mmxxo>-0.1 , c(l l) symbol(d s) graphregion(color(white)) l1("Average 1-day excess return, day t") ///
legend(ring(0) pos(12) size(medium)) ylabel(-0.1(0.1)0.3)   name(fig4A,replace)
graph export fig4A.pdf, replace

* PANEL B

for num 0/6: egen mxX=mean(ex1) if block==X, by(x5)
egen mxm1=mean(ex1) if block==-1, by(x5)

scatter mx0 mx2 mx4 mx6 avg_r, c(l l l l) ylabel(-0.3(0.1)0.6) mlabel(block block block block) legend(off) mlabpos(90)  graphregion(color(white)) t1("Each of the even weeks") name(g0, replace) nodraw
scatter mxm1 mx1 mx3 mx5 avg_r, c(l l l l) ylabel(-0.3(0.1)0.6) mlabel(block block block block) legend(off) mlabpos(90)  graphregion(color(white)) t1("Each of the odd weeks") name(g1, replace) nodraw
graph combine g0 g1,  graphregion(color(white)) scale(1.2) imargin(zero) name(fig4B,replace) 
graph export fig4B.pdf, replace


* FIGURE 5
* --------

clear
use fomc_data1
keep if year>=1994 
ge d5ep1=ep1[_n+4]-ep1[_n-1]
egen md5ep1=mean(d5ep1), by(cycle)
label variable md5ep1 "Change from t-1 to t+4"
so cycle
scatter md5ep1 cycle if cycle<=33, c(l) mlabel(cycle)  graphregion(color(white)) yscale(titlegap(-10))   title("1-month equity premium bound, 1996-Jan 2012")  name(fig5,replace)
graph export fig5.pdf, replace


* FIGURE 6
* --------


clear
use fomc_data1

ge day_after_fomc = 0 
replace day_after_fomc = 1 if cycle == 1 
reg wessel block0 block246 day_after_fomc day_after_minutes if cycle<=33 & year>=1994 & year<=2016, r

ge wessel_restricted=wessel*(cycle~=1)*(day_after_minutes==0)
ge wessel_restricted5=max(wessel_restricted,wessel_restricted[_n+1],wessel_restricted[_n+2],wessel_restricted[_n+3],wessel_restricted[_n+4])

egen mdw=mean(wessel), by(cycle)
egen mdw5=mean(wessel_restricted5), by(cycle)
label variable mdw " "
label variable mdw5 " "
so cycle

scatter mdw cycle if cycle<=33, mlabel(cycle cycle) c(l l) title("Probability of article on day t") symbol(o t) graphregion(color(white)) name(f1,replace)  nodraw
scatter mdw5  cycle if cycle<=33, mlabel(cycle cycle) c(l l) symbol(o t) legend(rows(2))  title("Probability of article on day t,...,t+4" "(Articles on day after FOMC/minutes excluded)") symbol(o t) graphregion(color(white)) name(f2,replace)   nodraw
so year month day
graph combine f1 f2,  graphregion(color(white)) name(fig6, replace)
graph export fig6.pdf, replace



* TABLE 1
* -------

* PANEL A (has 3 sets of t-stats)

clear
use fomc_data1
keep if cycle<=33 & year>=1994 & year<=2016

* column 1
eststo clear
eststo: qui reg ex1 block0246, robust
eststo: qui reg ex1 block0246, cluster(fomcblock) robust
eststo: qui newey ex1 block0246, lag(10) force
esttab, stats(N) b(a3) starlevels(*  0.10 ** 0.05 *** 0.010) label nogaps nonote

*column 2
eststo clear
eststo: qui reg ex1 block0 block246, robust
eststo: qui reg ex1 block0 block246, cluster(fomcblock) robust
eststo: qui newey ex1 block0 block246, lag(10) force
esttab, stats(N) b(a3) starlevels(*  0.10 ** 0.05 *** 0.010) label nogaps nonote

*column 3
eststo clear
eststo: qui reg ex1 block0 block2 block4 block6, robust
eststo: qui reg ex1 block0 block2 block4 block6, cluster(fomcblock) robust
eststo: qui newey ex1 block0 block2 block4 block6, lag(10) force
esttab, stats(N) b(a3) starlevels(*  0.10 ** 0.05 *** 0.010) label nogaps nonote

* PANEL B

clear
use fomc_data1
keep if cycle<=33 
eststo clear
eststo: qui reg ex1 block0 block246 if cycle<=33 & year>=2014 & year<=2016, robust
eststo: qui reg ex1 block0 block246 if cycle<=33 & year>=1994 & year<=2013, robust
eststo: qui reg ex1 block0 block246 if cycle<=33 & year<1994, robust
esttab, stats(N) b(a3) starlevels(*  0.10 ** 0.05 *** 0.010) label nogaps nonote

* PANEL C

clear
use fomc_data1
keep if cycle<=33 & year>=1994 & year <=2016

for any m r: egen sX=sum(ln(X)), by(year)
for any m r: egen sXeven=sum(ln(X)) if block0246==1, by(year)
for any m r: egen sXodd=sum(ln(X)) if block0246~=1, by(year)
for any m r: egen msXeven=max(sXeven), by(year)
for any m r: egen msXodd=max(sXodd), by(year)

for any m: egen ssX=sum(ln(X))
for any m: egen ssXeven=sum(ln(X)) if block0246==1
for any m: egen ssXodd=sum(ln(X)) if block0246~=1
for any m: egen mssXeven=max(ssXeven)
for any m: egen mssXodd=max(ssXodd)

so year month day
ge A=exp(sm)-exp(sr)
ge B=exp(msmeven)-exp(msreven)
ge C=exp(msmodd)-exp(msrodd)

ge AA=exp(ssm)
ge BB=exp(mssmeven)
ge CC=exp(mssmodd)

su A-C if year~=year[_n-1]
su AA-CC 


* TABLE 2
* -------


clear 
use fomc_data1

foreach v in DMxUS EM {
	gen ret_`v'_tplus1 = ret_`v'[_n+1]
}

eststo clear
eststo: qui reg ret_DMxUS_tplus1 block0 block246 if cycle<=33 & year>=1994 & year<=2016, robust 
eststo: qui reg ret_DMxUS_tplus1 block0 block2 block4 block6 if cycle<=33 & year>=1994 & year<=2016, robust 
eststo: qui reg ret_EM_tplus1 block0 block246 if cycle<=33 & year>=1994 & year<=2016, robust 
eststo: qui reg ret_EM_tplus1 block0 block2 block4 block6 if cycle<=33 & year>=1994 & year<=2016, robust 
esttab , stats(N) b(a3)  mlabel(DMxUS DMxUS EM EM) starlevels(* 0.10 ** 0.05 *** 0.01) label nogaps nonote


* TABLE 3
* -------

clear 
use fomc_data1

* reserve maintenance period dummies
for num 1/10: ge drmpX=rmp==X
for num 1/10: label var drmpX "Dummy=1 for day X of bank's reserve maintenance period"

* calendar dummies
gen dow=dow(date)
tabulate day, gen(dmd) 
for num 1/5: gen dwdX =(dow==X)
gen deoy = 0
replace deoy = 1 if year~=year[_n+1] & _n>1
gen deom = 0
replace deom = 1 if month~= month[_n+1] & _n>1
gen deoq = 0
gen yq = qofd(date)
bys yq :  replace deoq = 1 if _n==_N
drop yq 

for num 1/31: label var dmdX "Dummy=1 for day X of a month"
for num 1/5:  label var dwdX "Dummy=1 for day X of a week (1=Monday, 5=Friday)"
label var deoy "Dummy=1 on last day of a year" 
label var deoq "Dummy=1 on last day of a quarter"
label var deom "Dummy=1 on last day of a month"

replace cnt_eps = cnt_eps/10000

keep if year>=1994 & year<=2016
eststo clear
eststo: qui: reg ex1 block0 block246 if cycle<=33 , robust
eststo: qui: reg ex1 block0 block246 bbg_cnt_relw if cycle<=33 , robust
eststo: qui: reg ex1 block0 block246 cnt_eps frac_eps_pos if cycle<=33 , robust
eststo: qui: reg ex1 block0 block246 drmp* if cycle<=33 , robust
eststo: qui: reg ex1 block0 block246 dwd* dmd* deoy deom deoq if cycle<=33 , robust
esttab, stats(N) b(a3) indicate(drmp*  dwd* dmd* deoy* deom* deoq* )  starlevels(*  0.10 ** 0.05 *** 0.010) label nogaps nonote varwidth(30)




* TABLE 4
* -------

* PANEL A

clear
use fomc_data1
keep if year>=1994 
ge dtarget=fftarget-fftarget[_n-1]
gsort - t
li year month day dtarget cycle if dtarget~=0 & dtarget~=. & cycle~=0

* PANEL B

clear
use fomc_data1
ge change=fftarget[_n]~=fftarget[_n-1] & fftarget~=. & fftarget[_n-1]~=.
eststo clear
eststo: qui probit change block0 block246 if year>=1994 & cycle<=33
eststo: qui probit f(2).change block0 block246 if year<1994 & cycle<=33
esttab, stats(N) b(a3) starlevels(*  0.10 ** 0.05 *** 0.010) label nogaps nonote


* TABLE 5
* -------

clear
use fomc_data1

ge datadrop=year==2008 & month>=9
drop if datadrop==1
ge f=dff2 if year<=2008
replace f=dff24 if year>=2009

eststo clear
eststo: qui reg f block0 block246 if cycle<=33 & year>=2000 & year<=2016, r
eststo: qui reg f block0 block246 if cycle<=33 & year>=2000 & year<=2016  & x5==1, r
eststo: qui reg f block0 block246 if cycle<=33 & year>=2000 & year<=2016  & x5~=1, r
eststo: qui reg dff2 block0 block246 if cycle<=33 & year>=2000 & year<=2008  & x5==1, r
eststo: qui reg dff2 block0 block246 if cycle<=33 & year>=2000 & year<=2008  & x5~=1, r
eststo: qui reg dff24 block0 block246 if cycle<=33 & year>=2009 & year<=2016 & x5==1, r
eststo: qui reg dff24 block0 block246 if cycle<=33 & year>=2009 & year<=2016 & x5~=1, r
esttab, stats(N) b(a3) starlevels(*  0.10 ** 0.05 *** 0.010) label nogaps nonote


* TABLE 6
* -------

clear
use fomc_data1
keep if year>=1994

replace dr=0 if dr==.
ge dr5=max(dr[_n-1],dr[_n-2],dr[_n-3],dr[_n-4],dr[_n-5])
replace dr5=0 if dr5~=1

for num 0 2 4 6: ge blockXpost=blockX*dr5
ge block0246post=block0246*dr5
ge block0246nonpost=block0246*(dr5==0)
ge blockm1135post=(block0246==0)*dr5

eststo clear 
reg ex1 block0post block2post block4post block6post block0246nonpost blockm1135post if cycle<=33, robust
esttab, stats(N) b(a3) starlevels(*  0.10 ** 0.05 *** 0.010) label nogaps nonote

* TABLE 7
* -------

clear
use fomc_data1
keep if year>=1994 & cycle<=33

* PANEL A

eststo clear
eststo: qui reg ex1 block0 block246 if panic1==1, r
eststo: qui reg ex1 block0 block246 if panic1~=1, r
eststo: qui reg ex1 block0 block246 if panic2==1, r
eststo: qui reg ex1 block0 block246 if panic3==1, r
esttab, stats(N) b(a3) starlevels(*  0.10 ** 0.05 *** 0.010) label nogaps nonote

* PANEL B

ge one=1

* Column 1
table one , c(sum lnm n lnm) format(%9.6fc)
table one if panic1==1, c(sum lnm n lnm) format(%9.6fc)
table one if panic1~=1, c(sum lnm n lnm) format(%9.6fc)
table one if panic2==1, c(sum lnm n lnm) format(%9.6fc)
table one if panic3==1, c(sum lnm n lnm) format(%9.6fc)

* Column 2
table one if block0246==1, c(sum lnm n lnm) format(%9.6fc)
table one if panic1==1 & block0246==1, c(sum lnm n lnm) format(%9.6fc)
table one if panic1~=1 & block0246==1, c(sum lnm n lnm) format(%9.6fc)
table one if panic2==1 & block0246==1, c(sum lnm n lnm) format(%9.6fc)
table one if panic3==1 & block0246==1, c(sum lnm n lnm) format(%9.6fc)

* Column 3
table one if block0246==0, c(sum lnm n lnm) format(%9.6fc)
table one if panic1==1 & block0246==0, c(sum lnm n lnm) format(%9.6fc)
table one if panic1~=1 & block0246==0, c(sum lnm n lnm) format(%9.6fc)
table one if panic2==1 & block0246==0, c(sum lnm n lnm) format(%9.6fc)
table one if panic3==1 & block0246==0, c(sum lnm n lnm) format(%9.6fc)


* TABLE 8
* -------

clear
use fomc_data1

* Return calculations by FOMC cycle omit day -1 and 0 of the cycle which are particularly influenced by Fed policy.

* Total log returns for cycle>0, by FOMC cycle 
ge fomccyclepos=fomccycle
replace fomccyclepos=. if cycle<=0
egen mpos=sum(lnm), by(fomccyclepos)
egen fpos=sum(lnr), by(fomccyclepos)

* Total log returns for cycle<-1, by FOMC cycle 
ge fomccycleneg=fomccycle
replace fomccycleneg=. if cycle>=-1
egen mneg=sum(lnm), by(fomccycleneg)
egen fneg=sum(lnr), by(fomccycleneg)

* Total log returns, leading up to day 0 of current FOMC cycle (since previous day 0)
ge lnmc=mneg[_n-2]+mpos[_n-7] if cycle==0
ge lnfc=fneg[_n-2]+fpos[_n-7] if cycle==0

* Total log returns since day 0 of current FOMC cycle
ge rm0=lnm if cycle==0
replace rm0=rm0[_n-1]+lnm if rm0==.
ge rf0=lnr if cycle==0
replace rf0=rf0[_n-1]+lnr if rf0==.

* Total excess returns since day 0 of this FOMC cycle, this+last FOMC cycle, etc (variables cumexX).

so cycle year month day

ge rm1=(lnmc) if cycle==0
ge rm2=(lnmc+lnmc[_n-1]) if cycle==0 & cycle[_n-1]==0
ge rm3=(lnmc+lnmc[_n-1]+lnmc[_n-2]) if cycle==0 & cycle[_n-1]==0 & cycle[_n-2]==0
ge rm4=(lnmc+lnmc[_n-1]+lnmc[_n-2]+lnmc[_n-3]) if cycle==0 & cycle[_n-1]==0 & cycle[_n-2]==0 & cycle[_n-3]==0

ge rf1=(lnfc) if cycle==0
ge rf2=(lnfc+lnfc[_n-1]) if cycle==0 & cycle[_n-1]==0
ge rf3=(lnfc+lnfc[_n-1]+lnfc[_n-2]) if cycle==0 & cycle[_n-1]==0 & cycle[_n-2]==0
ge rf4=(lnfc+lnfc[_n-1]+lnfc[_n-2]+lnfc[_n-3]) if cycle==0 & cycle[_n-1]==0 & cycle[_n-2]==0 & cycle[_n-3]==0

so year month day
for num 1/4: replace rmX=rmX[_n-1] if rmX==.
for num 1/4: replace rfX=rfX[_n-1] if rfX==.

ge cumm0=rm0
ge cumf0=rf0
for num 1/4: ge cummX=rmX+rm0
for num 1/4: ge cumfX=rfX+rf0
for num 0/4: ge cumexX=exp(cummX)-exp(cumfX)

* Quintiles, by day since last day 0

ge zerocycle=0 if cycle==0
replace zerocycle=zerocycle[_n-1]+1 if zerocycle==.

keep if year>=1994 & year<=2016

for num 0/39: xtile ii0_X=cumex0 if zerocycle==X, nq(5)
for num 0/39: xtile ii1_X=cumex1 if zerocycle==X, nq(5)
for num 0/39: xtile ii2_X=cumex2 if zerocycle==X, nq(5)
for num 0/39: xtile ii3_X=cumex3 if zerocycle==X, nq(5)
for num 0/39: xtile ii4_X=cumex4 if zerocycle==X, nq(5)

for num 0/4: ge iiiX=iiX_0 if zerocycle==0
for num 0/39: replace iii0=ii0_X if zerocycle==X
for num 0/39: replace iii1=ii1_X if zerocycle==X
for num 0/39: replace iii2=ii2_X if zerocycle==X
for num 0/39: replace iii3=ii3_X if zerocycle==X
for num 0/39: replace iii4=ii4_X if zerocycle==X


so year month day
ge change=fftarget[_n]~=fftarget[_n-1] & fftarget~=. & fftarget[_n-1]~=.
gsort -t
li year month day cumex0-cumex4 iii0-iii4 if change==1 & cycle~=0 & year>=1994 & year<=2016


* TABLE 9
* -------

clear
use fomc_data1

for num 260: tssmooth ma smX=X*lnm*block0246*panic1, w(X)
for num 260: tssmooth ma srX=X*lnr*block0246*panic1, w(X)
for num 260: ge syXpanic1=exp(smX)-exp(srX)
drop sm* sr*

for num 260: tssmooth ma smX=X*lnm*block0246*panic2, w(X)
for num 260: tssmooth ma srX=X*lnr*block0246*panic2, w(X)
for num 260: ge syXpanic2=exp(smX)-exp(srX)
drop sm* sr*

for num 260: tssmooth ma smX=X*lnm*block0246*panic3, w(X)
for num 260: tssmooth ma srX=X*lnr*block0246*panic3, w(X)
for num 260: ge syXpanic3=exp(smX)-exp(srX)
drop sm* sr*

keep if cycle==0
so year month day
ge tt=_n
tsset tt
so tt

ge dtarget=fftarget-fftarget[_n-1]

eststo clear
eststo: qui newey l(0/2).dtarget sy260panic1 if year>=1994 & year<=2008 & sy260panic1~=., lag(7)
eststo: qui newey l(0/2).dtarget sy260panic2 if year>=1994 & year<=2008 & sy260panic1~=., lag(7)
eststo: qui newey l(0/2).dtarget sy260panic3 if year>=1994 & year<=2008 & sy260panic1~=., lag(7)
esttab, stats(N) b(a3) starlevels(*  0.10 ** 0.05 *** 0.010) label nogaps nonote


* TABLE 10
* --------

clear
use fomc_data1
keep if year>=1994

ge ep_m1=ep1
ge ep_m2=2*(ep2-(1/2)*ep_m1)
ge ep_m3=3*(ep3-(1/3)*(ep_m1+ep_m2))
ge ep_m4to6=2*(ep6-(1/2)*ep3)
ge ep_m7to12=2*(ep12-(1/2)*ep6)

ge dep_m1=ep_m1-ep_m1[_n-1]
ge dep_m2=ep_m2-ep_m2[_n-1]
ge dep_m3=ep_m3-ep_m3[_n-1]
ge dep_m4to6=ep_m4to6-ep_m4to6[_n-1]
ge dep_m7to12=ep_m7to12-ep_m7to12[_n-1]
ge dep12=ep12-ep12[_n-1]

eststo clear
eststo: qui reg dep_m1 block0 block246 if cycle<=33, r
eststo: qui reg dep_m2 block0 block246 if cycle<=33, r
eststo: qui reg dep_m3 block0 block246 if cycle<=33, r
eststo: qui reg dep_m4to6  block0 block246 if cycle<=33, r
eststo: qui reg dep_m7to12 block0 block246 if cycle<=33, r
eststo: qui reg dep12  block0 block246 if cycle<=33, r
eststo: qui reg dep12  block0 block246 if cycle<=33 & x5==1, r
eststo: qui reg dep12  block0 block246 if cycle<=33 & x5~=1, r
esttab, star(* 0.10 ** 0.05 *** 0.01) label nogaps nonote


* TABLE 11
* --------
clear
use fomc_data1
keep if year>=1994 & year<=2016


foreach v in chair vicechair president governor {

	gen cnt_`v' = cnt0_`v' + cntw_`v'
	gen ind_`v' = 0
	replace ind_`v' = 1 if cnt_`v' > 0 & cnt_`v'~=.
	gen indnxt_`v' = 0
	replace indnxt_`v' = 1 if cnt0_`v'[_n-1] > 0 & cnt0_`v'[_n-1] ~=.  // next day indicator only for nonweekend speeches
	
	label var ind_`v'  "Dummy=1 for `v' speech on day t (weekend speeches recorded on following Monday)"
	label var cnt_`v'  "Number of `v' speeches on day t (weekend speeches recorded on following Monday)"
	label var indnxt_`v'  "Dummy=1 for `v' speech on day t-1"
	
	di "Number of speeches for `v'"
	count if ind_`v' > 0 & ind_`v' ~=.
}


eststo clear 
eststo: qui reg ex1 block0 block246 if cycle<=33 , r
eststo: qui reg ex1 block0 block246 ind_bb ind_mn ind_drmn if cycle<=33, r 
eststo: qui reg ex1 block0 block246 ind_gover ind_vice ind_chair ind_pres  indnxt_gover  indnxt_vice indnxt_chair  indnxt_pres  if cycle<=33 , r
esttab ,  stats(N) b(a3)  mlabel("Baseline" "Fed documents" "Speeches")   starlevels(* 0.10 ** 0.05 *** 0.01) label nogaps nonote varwidth(50)

eststo clear 
eststo: qui reg ex1 if block0246 ==1 & ind_governor==1 , r
eststo: qui reg ex1 if block0246 ==0 & ind_governor==1 , r
esttab, stats(N) b(a3)  starlevels(* 0.10 ** 0.05 *** 0.01) label nogaps nonote  




* TABLE 13
* --------

clear
use fomc_data1

matrix drop _all
eststo clear 
* column 1
eststo Day_minus2_to_plus3: qui reg rx_m2_p3 if date>=td(1sep1982) & year(date)<1994, r
eststo Day_minus2_toFOMC: qui reg rx_m2_p0 if date>=td(1sep1982) & year(date)<1994, r
eststo FOMC_to_day3: qui reg rx_p0_p3 if date>=td(1sep1982) & year(date)<1994, r
esttab , stats(N) b(a3) mlabel(,title) modelwidth(25) title("1982:2-1993") label star(* 0.10 ** 0.05 *** 0.01)
* column 2
eststo Day_minus2_to_plus3: qui reg rx_m2_p3 if year(date)>=1994, r
eststo Day_minus2_toFOMC: qui reg rx_m2_p0 if year(date)>=1994, r
eststo FOMC_to_day3: qui reg rx_p0_p3 if year(date)>=1994, r
esttab , stats(N) b(a3) mlabel(,title) modelwidth(25) title("1994-2016") label star(* 0.10 ** 0.05 *** 0.01)






* APPENDIX TABLE 1
* ----------------

* PANEL A

clear
use fomc_data1

ge bk=1 if year>=1990 & year<=2002 
replace bk=1 if year==1989 & month>=6
replace bk=. if year==2001 & month==9 & day==17

ge post=1 if year>=2003 & year<=2008

replace expected = expected/100
replace surprise = surprise/100

ge mkt=(mktrf+rf)
eststo clear
eststo: qui reg mkt expected surprise if bk==1, r
eststo: qui reg mkt expected surprise if post==1, r

esttab, stats(N r2) b(a3) star(* 0.10 ** 0.05 *** 0.01)  label nogaps nonote 


* PANEL B

clear
use fomc_data1
keep if cycle==0
keep if year>=1994

drop if year<1994 | (year==1994 & month<9)
drop if year==1996 & month==3 & day==26
drop if year==1998 & month==7 & day==1

ge lm=year>=1995 & year<=2010
replace lm=1 if year==1994 & month>=9
replace lm=1 if year==2011 & month<=3

ge post=1 if year>1994 & lm~=1

eststo clear
* col 1: sep 1994-mar 2011
eststo: qui reg ret2pm if cycle==0 & lm==1, r
* col 2: apr 2011-dec 2016
eststo: qui reg ret2pm if cycle==0 & post==1,r 
esttab, stats(N) star(* 0.10 ** 0.05 *** 0.01)


* APPENDIX TABLE 2
* ----------------

clear
use fomc_data1

for num 2 10: replace dgsX=dgsX[_n-1] if dgsX==.
for num 2 10: ge ddgsX=dgsX-dgsX[_n-1] 

keep if cycle<=33 & year>=1994

* PANEL A

eststo clear
eststo: qui reg ddgs2 block0246, r
eststo: qui reg ddgs2 block0246 if x5==1, r
eststo: qui reg ddgs2 block0246 if x5~=1, r
eststo: qui reg ddgs10 block0246, r
eststo: qui reg ddgs10 block0246 if x5==1, r
eststo: qui reg ddgs10 block0246 if x5~=1, r
esttab, stats(N) b(a3) starlevels(*  0.10 ** 0.05 *** 0.010) label nogaps nonote

* PANEL B

eststo clear
eststo: qui reg ddgs2 block0246, r
eststo: qui reg ddgs2 block0246 if year<=2008, r
eststo: qui reg ddgs2 block0246 if year>=2009, r
eststo: qui reg ddgs10 block0246, r
eststo: qui reg ddgs10 block0246 if year<=2008, r
eststo: qui reg ddgs10 block0246 if year>=2009, r
esttab,  stats(N) b(a3) starlevels(*  0.10 ** 0.05 *** 0.010) label nogaps nonote



* APPENDIX FIGURE 1
* -----------------

clear
use fomc_data1
keep if year>=1994 & year<=2016

foreach v in DMxUS EM   {
so date
gen ret_`v'_tplus1 = ret_`v'[_n+1]/100
gen ret5_`v'_tplus1 = (1+ret_`v'_tplus1)*(1+ret_`v'_tplus1[_n+1])*(1+ret_`v'_tplus1[_n+2])*(1+ret_`v'_tplus1[_n+3])*(1+ret_`v'_tplus1[_n+4])-1
bysort cycle: egen ret5_cyc_`v'_tplus1 = mean((ret5_`v'_tplus1)*100)
label var ret5_`v'_tplus1 `v'
label var ret5_cyc_`v'_tplus1 `v'
}

so cycle 
scatter ret5_cyc_DMxUS_tplus1  ret5_cyc_EM_tplus1 cycle if cycle <= 33, c(l l) ml(cycle) msymbol(o d) ///
legend( pos(11) row(1) ring(0)  region(lwidth(none))  size(medium) lab(1 "Developed markets excluding US") lab(2 "Emerging markets") ) ylabel(-0.5(0.5)0.8) ///
ytitle("Avg. 5-day stock return, t+1 to t+5 (pct)") xtitle("Days since FOMC meeting (weekends excluded)")  graphregion(color(white)) name(fig1_appendix,replace)
graph export fig1_appendix.pdf, replace

* APPENDIX FIGURE 2
* -----------------

clear 
use fomc_data1
keep if date > td(31oct1996) & year<=2016
so date

bysort cycle : egen bbg_cnt_relw_cyc = mean(bbg_cnt_relw)
bysort cycle : egen bbg_cnt_cyc = mean(bbg_cnt)


sort cycle 
scatter bbg_cnt_relw_cyc bbg_cnt_cyc cycle if cycle<=33, c(l l) ml(cycle) mlabs(small)  yaxis(1) ///
ytitle("Avg. number of economic releases on day t")  ///
legend(lab(1 "Relevance-weighted avg. number of economic releases") lab(2 "Unweighted avg. number of economic releases") ///
ring(0) pos(11) region(lwidth(none) fcolor(none)) rows(2) size(medium))  graphregion(color(white)) name(fig2_appendix, replace)
graph export fig2_appendix.pdf, replace



* APPENDIX FIGURE 3
* -----------------


clear 
use fomc_data1

twoway line oi date if year>=1994 & year<2016, xlabel(,format(%tdCCYY)) xtitle("")  graphregion(color(white)) ///
xli(`=td(01jan2000)') name(fig3A_appendix, replace) 
graph export fig3A_appendix.pdf, replace


twoway line ffr_effective fftarget2008 fftarget_lb fftarget_ub date if year(date)>=1994 & year(date)<=2016 , ///
lc(red black black black) lp(solid solid dot dash ) lw(medium medthick medthick medthick) xlabel(,format(%tdCCYY)) xtitle("") ///
legend(ring(0) pos(2) cols(1) rows(4) size(medium)) ytitle("%p.a.") xli(`=td(01jan2000)') graphregion(color(white)) name(fig3B_appendix, replace) 
graph export fig3B_appendix.pdf, replace




* APPENDIX FIGURE 4
* -----------------

clear
use fomc_data1
keep if year>=1994 

egen avgex1=mean(ex1) if year>=1994, by(cycle)
label variable cycle "Days since FOMC meeting (weekends excluded)"
label variable avgex1 "Avg. 1-day stock minus T-bill return, day t (pct)"
so cycle
scatter avgex1 cycle if cycle<=33, c(l l l) mlabel(cycle) yla(-0.2(0.2).4) graphregion(color(white)) name(fig4_appendix, replace)
graph export fig4_appendix.pdf, replace


* APPENDIX FIGURE 5
* -----------------


clear
use fomc_data1
keep if year>=1994


* PANEL A 
bysort cycle: egen cnt_bb_cyc = sum(ind_bb)
	label var cnt_bb_cyc "Number of releases"
bysort cycle: egen cnt_mn_cyc = sum(ind_mn)
	label var cnt_mn_cyc "Number of releases"
bysort cycle: egen cnt_drmn_cyc = sum(ind_drmn)
	label var cnt_drmn_cyc "Number of releases"	

so cycle
scatter cnt_bb_cyc cycle if cycle <=33, c(l) xli(-10(10)30) name(fd2, replace) mlabel(cycle) ms(O) nodraw   title("Beigebooks, 1994-2016")  graphregion(color(white))
scatter cnt_mn_cyc cycle if cycle <=33, c(l) xli(-10(10)30) name(fd3, replace) mlabel(cycle) ms(O) nodraw title("Minutes of FOMC meetings, 1994-2016") graphregion(color(white))
scatter cnt_drmn_cyc cycle if cycle <=33 , c(l) xli(-10(10)30) name(fd4, replace) mlabel(cycle) ms(O) nodraw title("Minutes of discount rate meetings, 1994-96 (5 obs.), 2001-16") graphregion(color(white))
graph combine fd2 fd3 fd4, cols(2) rows(2)  graphregion(color(white)) name(fig5A_appendix,replace) imargin(small)
graph export fig5A_appendix.pdf, replace


* PANEL B 


foreach v in chair vicechair president governor {

	gen cnt_`v' = cnt0_`v' + cntw_`v'
	bysort cycle: egen cnt_`v'_cyc = sum(cnt_`v') 
	label var cnt_`v'_cyc "Number of speeches" 
	
}


gen cnt_all_speeches = cnt_chair + cnt_vicechair + cnt_president + cnt_governor
egen total_speeches = sum(cnt_all_speeches)
su total_speeches 


sort cycle
scatter cnt_president_cyc cycle if cycle<=33,  c(l) xli(-10(10)30) name(sp1, replace) mlabel(cycle)  ms(O) nodraw title("Regional Fed Presidents")  yscale(titlegap(*-5))
scatter cnt_chair_cyc cycle if cycle<=33, c(l) xli(-10(10)30) name(sp2, replace) mlabel(cycle)  ms(O) nodraw title("Chair")  yscale(titlegap(*-5))
scatter cnt_governor_cyc cycle if cycle<=33, c(l) xli(-10(10)30) name(sp3, replace) mlabel(cycle) ms(O)  nodraw title("Fed Governors")   yscale(titlegap(*-5))
scatter cnt_vicechair_cyc cycle if cycle<=33, c(l) xli(-10(10)30) name(sp4, replace) mlabel(cycle)  ms(O) nodraw title("Vice Chair")   yscale(titlegap(*-5))
graph combine sp2 sp1 sp4 sp3 ,    imargin(small) name(fig5B_appendix,replace) 
graph save "fig5B_appendix.pdf", replace



cap log close
