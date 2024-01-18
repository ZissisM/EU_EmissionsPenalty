use ukraine_17b

*imported dataset has generations, electricity prices, gas prices and coal prices
* import delimited "/Users/ZMarmarelis/Desktop/Taraq_transfer/EU_workspace/data/ukraine/_17_3b_regression_cleanV3.csv", clear 

*Should coal conversion be 6.978 instead of 8.14? (for europe)

gen double t=clock(t,"YMDhms")
format t %tc



*Effect of ETS price on gas (0.37) and coal (1)
*should use the exchange rate-- not 0.95
replace coal_p_c=price_usd_to_eur*price_coal_tonne/8.14+price_carbon
replace gas_p_c=price_gas+price_carbon*0.37


gen rel_p=gas_p_c/coal_p_c
gen rel_p_sq=rel_p^2
gen rel_p_cub=rel_p^3
gen load_sq=load^2
*load and y_all_renewables was converted to GWh from MWh



***NEW rel_price with CONVERTED CARBON PRICE

gen rel_testN= (price_gas+price_carbon*0.37*0.3)/(price_usd_to_eur*price_coal_tonne/8.14+price_carbon*0.3)
gen rel_testN2=rel_testN^2
gen rel_testN3=rel_testN^3

*use this one !!
replace coal_test=(price_usd_to_eur*price_coal_tonne)/8.14
gen rel_test=gas_p_c/coal_test


*total coal is y_coal_lignite
*capacity
*egen max_coal=max(total_coal) if year>2020,by(country)
egen max_coal=max(y_coal_lignite) if sample==1,by(country)

*capacity factor
gen cf_coal=(total_coal/max_coal)
*use y_coal_lignite for cf_coal!
*max_coal is just from y_coal_lignite


*for each country run regression (get marginal values for Fig3 scatters?), predict cf at different price (lower one Jan-March), multiply by capacity to get coal gen predicted --> Fig2C



*April 2021-May 2022 (inclusive) is sample period
gen sample=1 if dt>22370 & dt<22797 
replace sample=0 if missing(sample)


cap drop marginal_effect se_marginal_effect
cap gen marginal_effect = .
cap gen se_marginal_effect = .

//foreach y in  "GR"  {
foreach y in "BG" "CZ" "DE" "DK" "ES" "FI" "GR" "HR" "HU" "IT" "IE" "NL" "PL" "RO" {
	*country
	*ire or all_renewables, month FE?
	reg  cf_coal2 rel_testN rel_testN2 rel_testN3 ire load load_sq i.hour i.dow i.month if sample==1 & country=="`y'",cl(dt)
	//GR has different time FE because of how their gas market works
	//reg  cf_coal2 c.rel_test##c.rel_test##c.rel_test ire load load_sq i.hour i.dow c.dt if sample==1 & country=="GR",cl(dt)

	*pooled (can also do the cubics as c.rel_test##c.rel_test##c.rel_test)
	//reghdfe  cf_coal2 c.rel_testN##c.rel_testN##c.rel_testN  ire load load_sq if sample==1,absorb(panel_id dow hour month) cl(dt)
	//margins, dydx(rel_test) 
	*maybe
	//reghdfe  cf_coal2 rel_test rel_test2 rel_test3 ire load load_sq if sample==1,absorb(panel_id weekda hour month) cl(dt)

	*Marginal effect !

	sum rel_testN if sample==1
	//sum rel_test_gascap if sample==1
	local meanss = r(mean)
	sum rel_testN2 if sample==1
	//sum rel_test_gascap2 if sample==1
	local meanss2=r(mean)
	*average of marginal values (use meanss2) or marginal value at average (use meanss^2)?
	nlcom (marg: 3*_b[rel_testN3]* `meanss2' + 2 * `meanss' * _b[rel_testN2] + _b[rel_testN]),post
	replace marginal_effect2 = _b[marg] if country=="`y'"
	replace se_marginal_effect2 = _se[marg] if country=="`y'"

	*margins, dydx(rel_test) 
	*actually gives same answer

}
**make distinction to greece to not include month FE because they look at previous month prices???

//gen sig=1 if (marginal_effect2/ se_marginal_effect2>1.96)

*export to excel
putexcel set marginal_countriesMonthFE, replace

putexcel A1 = "Country"
putexcel B1= "Marginal Effect" //coefficient
putexcel C1= "SE" ///SE

local myrow = 2
foreach y in "BG" "CZ" "DE" "DK" "ES" "FI" "GR" "HR" "HU" "IT" "IE" "NL" "PL" "RO" {

	putexcel A`myrow' = "`y'"
	tabstat marginal_effect2 if country=="`y'",save
	putexcel B`myrow' = matrix(r(StatTotal))
	tabstat se_marginal_effect2 if country=="`y'",save
	putexcel C`myrow' = matrix(r(StatTotal))

	local myrow = `myrow' + 1
}

****prediction of cf_coal based on rel_test of pre-crisis and comapred to actual generation for each country for FIG2C?

egen avg_y_coal_lignite = mean(y_coal_lignite) if sample == 1, by(country)


cap drop  BG_counter-RO_counter
cap drop  RO_predictedCF
cap drop counter predictedCF
cap gen counter=.
cap gen predictedCF=.
cap drop excess
cap gen excess=.
cap gen excess2=.

//replace excess2=avg_y_coal_lignite-marginal_effect2*(1.058402-0.73272)*max_coal

foreach y in "BG" "CZ" "DE" "DK" "ES" "FI" "HR" "HU" "IT" "IE" "NL" "PL" "RO" {
	reg  cf_coal2 c.rel_testN##c.rel_testN##c.rel_testN ire load load_sq i.hour i.dow i.month if sample==1 & country=="`y'",cl(dt)
	*below margins command is the same as finding the marginal effect as above with nlcom
	* margins, dydx(rel_test)
	*2021 January-March (inclusive) mean rel_test is 0.73272// NOW it is  1.252849
	margins, at(rel_testN= 1.252849) post
	margins, coeflegend
	replace counter=_b[_cons] if country=="`y'"
	replace excess= avg_y_coal_lignite- counter*max_coal if country=="`y'"
	reg  cf_coal2 c.rel_testN##c.rel_testN##c.rel_testN ire load load_sq i.hour i.dow i.month if sample==1 & country=="`y'",cl(dt)
	//actual sample price is  1.878083
	margins, at(rel_testN= 1.878083) post
	*predicted CF is under the sample period relative price
	replace predictedCF=_b[_cons] if country=="`y'"
	//replace excess2= predictedCF*max_coal-counter*max_coal if country=="`y'"
}
reg  cf_coal2 c.rel_testN##c.rel_testN##c.rel_testN ire load load_sq i.hour i.dow c.dt if sample==1 & country=="GR",cl(dt)
margins, at(rel_testN=1.252849) post
replace excess= avg_y_coal_lignite- counter*max_coal if country=="GR"
reg  cf_coal2 c.rel_testN##c.rel_testN##c.rel_testN ire load load_sq i.hour i.dow c.dt if sample==1 & country=="GR",cl(dt)
margins, at(rel_testN=1.878083) post
replace predictedCF=_b[_cons] if country=="GR"

*excess EMISSIONS
egen coal_avg=mean(y_coal) if sample==1,by(country)
egen lignite_avg=mean(y_lignite) if sample==1,by(country)
replace coal_emissions=(coal_avg/avg_y_coal_lignite)*excess*830
replace lignite_emissions=(lignite_avg/avg_y_coal_lignite)*excess*1100

* average of others (dont use yet)
egen gas_avg=mean(y_gas) if sample==1,by(country)
egen otherfossil=mean(fossiloil+fossilcoalderivedgas+fossilpeat+fossiloilshale) if sample==1,by(country)

*emissions in mega tonne CO2 per year or kilotonnes (multiply by 1000)??
replace emissions=(coal_emissions+lignite_emissions)*24*365/1000000

replace baseline_emissions=coal_avg*830+lignite_avg*1100
replace relative_emissions=(coal_emissions+lignite_emissions)/baseline_emissions
tabstat relative_emissions,by(country)
egen baseline_gen=mean(y_coal_lignite) if year>2020,by(country)
gen relative_gen=excess/baseline_gen
tabstat relative_gen,by(country)



*Fig 2E Gas or Coal??
//replace total_emissions= ((coal_avg/avg_y_coal_lignite)*excess_3*830 + (lignite_avg/avg_y_coal_lignite)*excess_3*1100)+(gas_avg*370)+(otherfossil*700)*24*365/1000000000
//replace total_emissions= ((coal_avg/avg_y_coal_lignite)*excess_3*830 + (lignite_avg/avg_y_coal_lignite)*excess_3*1100)*24*365/1000000000
//preserve
//collapse total_emissions,by(country)
//egen total_EU=total(total_emissions)
*total is 445.473 in previous main specification, without gas or others
//restore



putexcel set excess_coal, replace

putexcel A1 = "Country"
putexcel B1= "Excess Coal" //panel C
putexcel C1= "Excess Emissions" ///panel D

local myrow = 2
foreach y in "BG" "CZ" "DE" "DK" "ES" "FI" "GR" "HR" "HU" "IT" "IE" "NL" "PL" "RO" {

	putexcel A`myrow' = "`y'"
	tabstat excess if country=="`y'",save
	putexcel B`myrow' = matrix(r(StatTotal))
	tabstat emissions if country=="`y'",save
	putexcel C`myrow' = matrix(r(StatTotal))
	local myrow = `myrow' + 1
}

**How excess was calculated by taraq.. is this right? Or should I use margins to calcualte it at each separate one? Effectively using a prediction here what it wouldve been (at 1.085 price) instead of the actual data (B)
//replace excess_dif=(marginal_effect*1.058402-marginal_effect*0.73272)*max_coal




*Fig 3 (missing the insignificants) should collapse to get 1 point per country 


gen m1=1


use Fig3_ukraine


cap gen exclude=0
replace exclude=1 if country=="HU"
replace exclude=1 if country=="GR"
replace exclude=1 if country=="RO"
replace exclude=1 if country=="IE"

*For including all, otherwise comment
replace exclude=0

replace m1=2 if country=="DK"
replace m1=3 if country=="PL"
replace m1=7 if country=="CZ"
replace m1=3 if country=="HU"
replace m1=11 if country=="BG"
replace m1=10 if country=="NL"
replace m1=9 if country=="FI"
replace m1=1 if country=="DE"


*mm for robust regression to discount outliers
robreg mm marginal_effect2 y_gas_pct if exclude==0
matrix b=e(b)
**both OLS and mm lines included, in addition to dots for each Country
twoway  lfitci marginal_effect2 y_gas_pct if exclude==0, lcolor(purple*0.01) lwidth(*0.000001)  ciplot(rarea) acolor(sand%50)|| scatter marginal_effect2 y_gas_pct if exclude==0 , mlabel(labels) mlabvposition(m1) mlabsize(*1.28) msymbol(d) mcolor(sienna%75) msize(*2.02) color(navy) graphregion(lstyle(none)) title("A)",position(11) size(*1.95)) xtitle("Natural Gas share",size(*1.27)) ylabel(,labsize(*1.6) grid gmax gmin glwidth(0.5)) legend(off) xlabel(,labsize(*1.4)) ytitle(Responsiveness of Coal (CF) to Relative Price,size(*1.1)) name(gas,replace)  ||function y=_b[y_gas_pct]*x+_b[_cons] if exclude==0,range(y_gas_pct) lcolor(purple*0.5) lwidth(*1.5) lpattern(solid)


replace m1=3 if country=="BG"
replace m1=3 if country=="IT"
replace m1=9 if country=="PL"
replace m1=1 if country=="FI"
replace m1=6 if country=="NL"
replace m1=1 if country=="DK"
replace m1=3 if country=="RO"
replace m1=6 if country=="HU"
replace m1=9 if country=="GR"



robreg mm marginal_effect2 y_coal_lignite_pct if exclude==0
//matrix b=e(b)
**both OLS and mm lines included, in addition to dots for each Country
twoway  lfitci marginal_effect2 y_coal_lignite_pct if exclude==0, lcolor(purple*0.01) lwidth(*0.000001) ciplot(rarea) acolor(sand%50)|| scatter marginal_effect2 y_coal_lignite_pct if exclude==0 , mlabel(labels) mlabvposition(m1) mlabsize(*1.28) msymbol(d) mcolor(sienna%75) msize(*2.02) color(navy) graphregion(lstyle(none)) title("B)",position(11) size(*1.95)) xtitle("Coal & Lignite share",size(*1.27)) ylabel(,labsize(*1.6) grid gmax gmin glwidth(0.5)) legend(off) xlabel(,labsize(*1.4)) ytitle(Responsiveness of Coal (CF) to Relative Price,size(*1.1)) name(coal,replace) ||function y=_b[y_coal_lignite_pct]*x+_b[_cons] if exclude==0,range(y_coal_lignite_pct) lcolor(purple*0.5) lwidth(*1.5) lpattern(solid)


replace m1=7 if country=="PL"
replace m1=11 if country=="BG"
replace m1=2 if country=="NL"
replace m1=1 if country=="FI"
replace m1=6 if country=="CZ"
replace m1=4 if country=="HU"
replace m1=1 if country=="GR"



robreg mm marginal_effect2 sol_wind if exclude==0
//matrix b=e(b)
**both OLS and mm lines included, in addition to dots for each Country
twoway  lfitci marginal_effect2 sol_wind if exclude==0, lcolor(purple*0.01) lwidth(*0.000001) ciplot(rarea) acolor(sand%50)|| scatter marginal_effect2 sol_wind if exclude==0 , mlabel(labels) mlabvposition(m1) mlabsize(*1.28) msymbol(d) mcolor(sienna%75) msize(*2.02) color(navy) graphregion(lstyle(none)) title("C)",position(11) size(*1.95)) xtitle("Solar & Wind share",size(*1.27)) ylabel(,labsize(*1.6) grid gmax gmin glwidth(0.5)) legend(off) xlabel(,labsize(*1.4)) ytitle(Responsiveness of Coal (CF) to Relative Price,size(*1.1)) name(RE,replace) ||function y=_b[sol_wind]*x+_b[_cons] if exclude==0,range(sol_wind) lcolor(purple*0.5) lwidth(*1.5) lpattern(solid)


replace m1=1 if country=="PL"
replace m1=4 if country=="HR"
replace m1=3 if country=="DE"
replace m1=3 if country=="NL"
replace m1=9 if country=="HU"
replace m1=3 if country=="GR"
replace m1=3 if country=="IE"




robreg mm marginal_effect2 y_nuclear_pct if exclude==0
//matrix b=e(b)
**both OLS and mm lines included, in addition to dots for each Country
twoway  lfitci marginal_effect2 y_nuclear_pct if exclude==0,lcolor(purple*0.01) lwidth(*0.000001) ciplot(rarea) acolor(sand%50)|| scatter marginal_effect2 y_nuclear_pct if exclude==0 , mlabel(labels) mlabvposition(m1) mlabsize(*1.28) msymbol(d) mcolor(sienna%75) msize(*2.02) color(navy) graphregion(lstyle(none)) title("D)",position(11) size(*1.95)) xtitle("Nuclear share",size(*1.27)) ylabel(,labsize(*1.6) grid gmax gmin glwidth(0.5)) legend(off) xlabel(,labsize(*1.4)) ytitle(Responsiveness of Coal (CF) to Relative Price,size(*1.1)) name(Nuc,replace) ||function y=_b[y_nuclear_pct]*x+_b[_cons] if exclude==0,range(y_nuclear_pct) lcolor(purple*0.5) lwidth(*1.5) lpattern(solid)

graph combine gas coal RE Nuc, altshrink name(Fig3,replace)


***Fig 4 / Counterfactuals ****

*gas price if gas cap at 180
gen gas_price_capped=price_gas
*******how many times? (needs to be 3 consecutive days????)
replace gas_price_capped=180 if price_gas>180
gen gas_price_cappedC=gas_price_capped+price_carbon*0.37
replace rel_test_gascap=gas_price_cappedC/coal_p_c
replace rel_test_gascap2=rel_test_gascap^2


**This one!! Converted carbon price
gen gas_price_cappedN=price_gas
replace gas_price_cappedN=180 if price_gas>180
replace gas_price_cappedCN=gas_price_cappedN+price_carbon*0.3*0.37
gen rel_gascapN=gas_price_cappedCN/(price_usd_to_eur*price_coal_tonne/8.14+price_carbon*0.3)



*1.049069 for sample (vs 1.0584)
sum rel_test_gascap if sample==1
*1.40098 vs 1.351114 for 2022
sum rel_test rel_test_gascap if year==2022

*In sample change in coal generation DECREASE
//replace diff_sampleCap=(1.058402-1.049069)*marginal_effect2*max_coal
replace diff_sampleCapN=( 1.878083- 1.873292)*marginal_effect2*max_coal



gen predictedCF2022_counter=.
foreach y in "BG" "CZ" "DE" "DK" "ES" "FI" "HR" "HU" "IT" "IE" "NL" "PL" "RO" {
	reg  cf_coal2 c.rel_testN##c.rel_testN##c.rel_testN ire load load_sq i.hour i.dow i.month if sample==1 & country=="`y'",cl(dt)
	margins, at(rel_test=2.364759) post
	replace predictedCF2022=_b[_cons] if country=="`y'"
	reg  cf_coal2 c.rel_testN##c.rel_testN##c.rel_testN ire load load_sq i.hour i.dow i.month if sample==1 & country=="`y'",cl(dt)
	margins, at(rel_test=2.247722) post
	replace predictedCF2022_counter=_b[_cons] if country=="`y'"


}
reg  cf_coal2 c.rel_testN##c.rel_testN##c.rel_testN ire load load_sq i.hour i.dow if sample==1 & country=="GR",cl(dt)
margins, at(rel_test=2.364759) post
replace predictedCF2022=_b[_cons] if country=="GR"
reg  cf_coal2 c.rel_testN##c.rel_testN##c.rel_testN ire load load_sq i.hour i.dow if sample==1 & country=="GR",cl(dt)
margins, at(rel_test=2.247722) post
replace predictedCF2022_counter=_b[_cons] if country=="GR"

**Prediction of what 2022 would be under actual prices
***0.007224 or 0.049866--- the difference between gas price and gas price cap under each period 
*DECREASE in 2022 if cap was in place
*USE THIS

gen diff_2022CapN=( 2.364759-2.247722)*marginal_effect2*max_coal2022


**Using actual coal average generation, subtract the prediction under the cap 
egen avg_y_coal_lignite_2022=mean(y_coal_lignite) if year==2022, by(country)
egen max_coal2022=max(y_coal_lignite) if year==2022,by(country)

// *which one?
// gen counter_2022=avg_y_coal_lignite_2022-marginal_effect2*1.351114*max_coal2022
// gen gasCounter_excess=avg_y_coal_lignite_2022-predictedCF2022_counter*max_coal2022

*mean of rel_test_gascap is   1.049069.. not that different? UNDER SAMPLE , under previously non converted carbon

**the way taraq does it is he gets the difference in price ratios and multiplies it by ther marginal effect, and adds that onto the actual data CF??

cap drop  BG_counterGasCap-RO_counterGasCap
cap drop counterGasCap
gen counterGasCap=.
foreach y in "BG" "CZ" "DE" "DK" "ES" "FI" "GR" "HR" "HU" "IT" "IE" "NL" "PL" "RO" {
	//foreach y in "BG"{
	reg  cf_coal2 c.rel_test##c.rel_test##c.rel_test y_all_renewables load load_sq i.hour i.weekda if sample==1 & country=="`y'",cl(dt)
	//margins,at(rel_test=0.73272) post 
	*1.058402 (normal sample average) vs  1.049069 (Gas CAP average)
	*dydx(rel_test) 
	//margins, at(rel_test=(0.7(0.01)1.2)) post
	//marginsplot, recast(connected) noci name(marg`y',replace) xtitle("Relative price (EUR/MWh)") ytitle("Predicted coal CF") title(`y')
	margins,at(rel_test=1.049069) post 
	replace counterGasCap=_b[_cons] if country=="`y'"
}





//marginal_effect2 y_gas_pct if exclude==0, ci coef vce(robust) mlabel(country) msize(*0.85) jitter(5)



*Using the estimates, predict the CF based on the futures of gas and coal


*Hirth paper elasticity around 0.05? (So gas price increase would reduce electricity usage by some amount,less emissions?)
*Gas price cap would lead to more electricity in general (elasticity?) but perhaps less coal (but what is the carbon tax for the equivalent savings?) 
*carbon price disincnetivzes electricity comapred to gas cap (with carbon price even higher electricity price so less usage)

*what about subsidies in various countries for electricity or gas?  Ignore?
*carbon price revenues per country--> are they more or less than the windfall profits from inframarginal?


**



**Find equiavalent carbon 
** needs to be done for 2022 and not sample
use prices_2022_ukraine
cap drop diff carbon_tax temp temp_mean
cap drop diff carbon_tax
gen diff = .
gen carbon_tax = .

local min_diff = 10
local optimal_tax = .
forval i = 100(1)20000 {
    local x = `i' / 1000
    quietly gen temp = (price_gas + `x'*0.37*0.3+price_carbon*0.37*0.3) / (coal_p + (price_carbon+`x')*0.3)
    quietly egen temp_mean = mean(temp)
	*1.049069 is the average price gas capped in sample  --2.247722 is new price after carbon conevrsion
    quietly replace diff = abs(temp_mean - 2.247722) 

    summarize diff, meanonly 
    local this_mean_diff = r(mean)

    if `this_mean_diff' < `min_diff' {
        local min_diff = `this_mean_diff'
        local optimal_tax = `x'
    }
    else if `this_mean_diff' == `min_diff' {
        local optimal_tax = `optimal_tax'
    }

    drop temp temp_mean
}
replace carbon_tax = `optimal_tax'

replace carbon_tax=12.18
replace rel_test_carbonTax=(price_gas+price_carbon*0.37*0.3+carbon_tax*0.37*0.3)/(coal_p+carbon_tax*0.3+price_carbon*0.3)
sum rel_test_carbonTax rel_gascapN if year==2022
*Same!



// *Greece delayed gas prices
// sum rel_test_GR if sample==1
// //sum rel_test_gascap if sample==1
// local meanss = r(mean)
// sum rel_test_GR if sample==1
// //sum rel_test_gascap2 if sample==1
// local meanss2=r(mean)
// *average of marginal values (use meanss2) or marginal value at average (use meanss^2)?
// nlcom (marg: 3*_b[c.rel_test_GR#c.rel_test_GR#c.rel_test_GR]* `meanss2' + 2 * `meanss' * _b[ c.rel_test_GR#c.rel_test_GR] + _b[ rel_test_GR]),post



*Electricity Change from Gas Cap (*Do the same with other carbon tax prices, which would have opposite effect (higher price and less electricity demand))

replace change_gaspriceCap=(gas_price_capped-price_gas)

* I Think need to multiply by emissions factor (like 0.3) to get EUR/MWh. Equivalent carbon tax should probably change?

replace change_carbonTax=(carbon_tax*emissions_fac)
*now in EUR/MWh once multiplied by emissions factor 



*multiply this by pass-through estimates
*passthrough, get table for EDF
cap drop passthrough rel_price_change
gen passthrough=.
gen rel_price_change=.
cap gen marginal_load_passthrough=.
**no IE
foreach y in "BG" "CZ" "DE" "DK" "ES" "FI" "GR" "HR" "HU" "IT" "NL" "PL" "RO" {
	reg electricity_prices price_gas i.month i.hour i.dow ire c.load##c.load if country=="`y'" & year>2020,cl(dt)
	replace passthrough=_b[price_gas] if country=="`y'"
	//local meanss = r(mean)
	//nlcom  2 * _b[c.load#c.load] * `meanss' + _b[load]
	//replace marginal_load_passthrough = 2 * _b[c.load#c.load] * `meanss' + _b[load] if country=="`y'"
	if "`y'"=="BG"{
		outreg2  using "passthrough.xls",  replace addtext(Month FE, YES, Hour FE, YES, Day of Week FE, YES) keep(price_gas ire load c.load#c.load)  label ctitle(`y') nocons bdec(3) sdec(3) excel
	}
	else{
		outreg2  using "passthrough.xls",  append addtext(Month FE, YES, Hour FE, YES, Day of Week FE, YES) keep(price_gas ire load c.load#c.load)  label ctitle(`y') nocons bdec(3) sdec(3) excel
	}
	if "`y'"=="GR"{
		reg electricity_prices price_gas i.hour i.dow ire c.load##c.load c.dt if country=="GR" & year>2020,cl(dt)
		replace passthrough=_b[price_gas] if country=="GR"
		outreg2  using "passthrough.xls",  append addtext(Month FE, YES, Hour FE, YES, Day of Week FE, YES) keep(price_gas ire load c.load#c.load)  label ctitle(`y') nocons bdec(3) sdec(3) excel 
	}
}

***SI Passthorugh ROBUSTNESS (2022)
foreach y in "BG" "CZ" "DE" "DK" "ES" "FI" "GR" "HR" "HU" "IT" "NL" "PL" "RO" {
	reg electricity_prices price_gas i.month i.hour i.dow ire c.load##c.load if country=="`y'" & year>2021,cl(dt)
	//local meanss = r(mean)
	//nlcom  2 * _b[c.load#c.load] * `meanss' + _b[load]
	//replace marginal_load_passthrough = 2 * _b[c.load#c.load] * `meanss' + _b[load] if country=="`y'"
	if "`y'"=="BG"{
		outreg2  using "passthrough_22.doc",  replace addtext(Month FE, YES, Hour FE, YES, Day of Week FE, YES) keep(price_gas ire load c.load#c.load)  label ctitle(`y') nocons bdec(3) sdec(3) excel
	}
	else{
		outreg2  using "passthrough_22.doc",  append addtext(Month FE, YES, Hour FE, YES, Day of Week FE, YES) keep(price_gas ire load c.load#c.load)  label ctitle(`y') nocons bdec(3) sdec(3) excel
	}
	if "`y'"=="GR"{
		reg electricity_prices price_gas i.hour i.dow ire c.load##c.load c.dt if country=="GR" & year>2021,cl(dt)
		outreg2  using "passthrough_22.doc",  append addtext(Month FE, YES, Hour FE, YES, Day of Week FE, YES) keep(price_gas ire load c.load#c.load)  label ctitle(`y') nocons bdec(3) sdec(3) excel 
	}
}




**change in PRICE 
egen avg_electricity=mean(electricity_prices) if year==2022,by(country)
egen avg_load=mean(load) if year==2022,by(country)

replace rel_price_change=change_gaspriceCap
replace change_electricityPriceGasCap=(rel_price_change*passthrough)
replace rel_price_change=change_carbonTax
replace change_electricityPriceCarbonTax=(rel_price_change*passthrough)*0.37

tabstat change_electricityPriceGasCap change_electricityPriceCarbonTax if year==2022,by(country)


*maybe 0.3? SI for others below
replace elasticity=-0.15

*multiply this PRICE change by the elasticity estimate, in MWh
replace change_electricityGenGasCap=change_electricityPriceGasCap/avg_electricity*elasticity*avg_load*1000
replace change_electricityGenCarbonTax=change_electricityPriceCarbonTax/avg_electricity*elasticity*avg_load*1000

tabstat change_electricityGenGasCap change_electricityGenCarbonTax if year==2022,by(country)

****SI VERSIONS OF DIFFERENT ELASTICITY****

use elasticity_SI

replace elasticity=-0.05
replace change_electricityGenGasCap=change_electricityPriceGasCap/avg_electricity*elasticity*avg_load*1000
replace change_electricityGenCarbonTax=change_electricityPriceCarbonTax/avg_electricity*elasticity*avg_load*1000
gen change_emissionsGasCapLow=change_electricityGenGasCap*emissions_fac*24*365/1000
gen change_emissionsCarbonTaxLow=change_electricityGenCarbonTax*emissions_fac*24*365/1000

replace elasticity=-0.35
replace change_electricityGenGasCap=change_electricityPriceGasCap/avg_electricity*elasticity*avg_load*1000
replace change_electricityGenCarbonTax=change_electricityPriceCarbonTax/avg_electricity*elasticity*avg_load*1000
gen change_emissionsGasCapHigh=change_electricityGenGasCap*emissions_fac*24*365/1000
gen change_emissionsCarbonTaxHigh=change_electricityGenCarbonTax*emissions_fac*24*365/1000


putexcel set Fig4_elasticityrobust, replace
putexcel A1 = "Country"
putexcel B1= "Emissiosn Change Gas Cap Low" 
putexcel C1= "Emissiosn Change Carbon Tax Low" 
putexcel D1= "Emissiosn Change Gas Cap High" 
putexcel E1= "Emissiosn Change Carbon Tax High" 

local myrow = 2
foreach y in "BG" "CZ" "DE" "DK" "ES" "FI" "GR" "HR" "HU" "IT" "NL" "PL" "RO" {

	putexcel A`myrow' = "`y'"
	tabstat  change_emissionsGasCapLow if country=="`y'" &year==2022,save
	putexcel B`myrow' = matrix(r(StatTotal))
	tabstat  change_emissionsCarbonTaxLow if country=="`y'"  &year==2022,save
	putexcel C`myrow' = matrix(r(StatTotal))
	tabstat  change_emissionsGasCapHigh if country=="`y'"  &year==2022,save
	putexcel D`myrow' = matrix(r(StatTotal))
	tabstat  change_emissionsCarbonTaxHigh if country=="`y'"  &year==2022,save
	putexcel E`myrow' = matrix(r(StatTotal))
	local myrow = `myrow' + 1
}

import excel "/Users/ZMarmarelis/Downloads/Fig4_elasticityrobust.xlsx", sheet("Sheet1") firstrow


graph bar EmissiosnChangeGasCapLow EmissiosnChangeCarbonTaxLow  ,over(Country)  legend( label(1 "180 EUR/MWh Natural Gas Cap: Low Demand Elasticity") label(2 "Equivalent Carbon Tax: Low Demand Elasticity") ring(1) position(6))  ytitle("Output Effect Emissions (Ktonnes CO2/Year)",size(*0.9))  asyvars bar(2,color(purple)) bar(1,color(emerald)) intensity(50) name(EmissionsChangeElasticitiesLow,replace) title("A)",position(11)  size(*1))

graph bar  EmissiosnChangeGasCapHigh EmissiosnChangeCarbonTaxHigh ,over(Country)  legend( label(1 "180 EUR/MWh Natural Gas Cap: High Demand Elasticity") label(2 "Equivalent Carbon Tax: High Demand Elasticity") ring(1) position(6))  ytitle("Output Effect Emissions (Ktonnes CO2/Year)",size(*0.9))  asyvars bar(2,color(purple)) bar(1,color(emerald)) intensity(50) name(EmissionsChangeElasticitiesHigh,replace) title("B)",position(11)  size(*1))

// 	gen total_emissionsCapLow=-sub+EmissiosnChangeGasCapLow
// 	gen total_emissionsTaxLow=EmissiosnChangeCarbonTaxLow-sub 
// 	gen total_emissionsCapHigh=-sub+EmissiosnChangeGasCapHigh
// 	gen total_emissionsTaxHigh=EmissiosnChangeCarbonTaxHigh-sub 

graph bar total_emissionsCapLow total_emissionsTaxLow ,over(Country) legend( label(1 "180 EUR/MWh Natural Gas Cap: Low Demand Elasticity") label(2 "Equivalent Carbon Tax: Low Demand Elasticity") ring(1) position(6))  ytitle("Total Emissions Change (Ktonnes CO2/Year)",size(*0.9)) asyvars bar(2,color(khaki)) bar(1,color(ebblue)) intensity(50) name(TotalL,replace) title("C)",position(11)  size(*1))

graph bar total_emissionsCapHigh total_emissionsTaxHigh ,over(Country) legend( label(1 "180 EUR/MWh Natural Gas Cap: High Demand Elasticity") label(2 "Equivalent Carbon Tax: High Demand Elasticity") ring(1) position(6))  ytitle("Total Emissions Change (Ktonnes CO2/Year)",size(*0.9)) asyvars bar(2,color(khaki)) bar(1,color(ebblue)) intensity(50) name(TotalH,replace) title("D)",position(11)  size(*1))


graph combine  EmissionsChangeElasticitiesLow EmissionsChangeElasticitiesHigh TotalL TotalH,name(elasticities,replace) 

*************


*Elasticity of demand? month fe? sample only or average over all?
*units of MWh/price
*Find value in literature assumptions !
//ivregress 2sls load i.month i.hour i.dow  (electricity_prices= y_wind) if country=="ES",vce(robust)

*then to emissions with average capacity factor (gCO2/KWh)-->Mtonnes per Year?
//replace avg_emissions= (coal_avg*830+lignite_avg*1100+gas_avg*370+otherfossil*700)/avg_load *24*365/1000000000
**/1000000000*24*365 (Mtonnes?)

*100000 (1 million grams in a metric tonne)
*replace change_emissionsGasCap=change_electricityGenGasCap*avg_emissions
*replace change_emissionsCarbonTax=change_electricityGenCarbonTax*avg_emissions

replace change_emissionsGasCap=change_electricityGenGasCap*emissions_fac*24*365/1000
replace change_emissionsCarbonTax=change_electricityGenCarbonTax*emissions_fac*24*365/1000

*units? KILOTONNES/YEAR
tabstat change_emissionsGasCap change_emissionsCarbonTax sub_emissions_year if year==2022,by(country)


*emissions in mega tonne CO2 per year or kilotonnes (multiply by 1000)?? 
replace substitution_emissions=(diff_2022CapN*(coal_avg/avg_y_coal_lignite)*830)+(diff_2022CapN*(lignite_avg/avg_y_coal_lignite)*1100)

replace sub_emissions_year=substitution_emissions*24*365/1000000

tabstat sub_emissions_year,by(country)


putexcel set Fig4_new2, replace

putexcel A1 = "Country"
putexcel B1= "Price Change Gas Cap" 
putexcel C1= "Price Change Carbon Tax" 
putexcel D1="Average emissions factor"
putexcel E1="Emissions Change Gas Cap"
putexcel F1="Emissions Change Carbon Tax"
putexcel G1="Emissions Change 2022"



*no IE
local myrow = 2
foreach y in "BG" "CZ" "DE" "DK" "ES" "FI" "GR" "HR" "HU" "IT" "NL" "PL" "RO" {

	putexcel A`myrow' = "`y'"
	tabstat  change_electricityPriceGasCap if country=="`y'" &year==2022,save
	putexcel B`myrow' = matrix(r(StatTotal))
	tabstat  change_electricityPriceCarbonTax if country=="`y'"  &year==2022,save
	putexcel C`myrow' = matrix(r(StatTotal))
	tabstat  emissions_fac if country=="`y'"  &year==2022,save
	putexcel D`myrow' = matrix(r(StatTotal))
	tabstat  change_emissionsGasCap if country=="`y'"  &year==2022,save
	putexcel E`myrow' = matrix(r(StatTotal))
	tabstat  change_emissionsCarbonTax if country=="`y'"  &year==2022,save
	putexcel F`myrow' = matrix(r(StatTotal))
	tabstat sub_emissions_year if country=="`y'"  &year==2022,save
	putexcel G`myrow' = matrix(r(StatTotal))


	local myrow = `myrow' + 1
}



import excel "/Users/ZMarmarelis/Downloads/Fig4_new.xlsx", sheet("Sheet1") firstrow clear

use Fig4_ukraine

replace total_emissionsCap=-EmissionsChange2022+EmissionsChangeGasCap

replace total_emissionsTax=EmissionsChangeCarbonTax-EmissionsChange2022 

*revpass is passthrough from 1 EURO in price (per CO2 tonne) to country revenue
*replace Carbon_Revenue=12.18*rev_pass*Averageemissionsfactor/(avg_load*1000)

*divide by 1000 to be in thousands euros
replace Carbon_Revenue=12.18*avg_load*1000/Averageemissionsfactor/1000


graph bar PriceChangeGasCap PriceChangeCarbonTax  ,over(Country)  legend( label(1 "180 EUR/MWh Natural Gas Cap") label(2 "Equivalent (12.18 EUR/tonne) Carbon Tax") ring(1) position(6)) ytitle("2022 Wholesale Electricity Price Change (EUR/MWh)",size(*0.88)) asyvars bar(2,color(maroon)) bar(1,color(green)) intensity(50) name(PriceChange,replace) title("A)",position(11) size(*1.5))

graph bar EmissionsChangeGasCap EmissionsChangeCarbonTax ,over(Country)  legend( label(1 "180 EUR/MWh Natural Gas Cap") label(2 "Equivalent (12.18 EUR/tonne) Carbon Tax") ring(1) position(6)) ytitle("Output Effect Emission Change (Ktonnes CO2/Year)",size(*0.88))  asyvars bar(2,color(purple)) bar(1,color(emerald)) intensity(50) name(EmissionsChange,replace) title("C)",position(11)  size(*1.5))

graph bar total_emissionsCap total_emissionsTax ,over(Country) legend( label(1 "180 EUR/MWh Natural Gas Cap") label(2 "Equivalent (12.18 EUR/tonne) Carbon Tax") ring(1) position(6))  ytitle("Total Emissions Change (Ktonnes CO2/Year)") asyvars bar(2,color(khaki)) bar(1,color(ebblue)) intensity(50) name(Total,replace) title("D)",position(11)  size(*1.5))

**NEED TO FIGURE OUT UNITS HERE FOR REVENUE AND BURDEN
*divide by 1000 to be in thousands
replace totalBurdenTax=(avg_load*PriceChangeCarbonTax*1000)/1000
replace totalBurdenCap=(avg_load*PriceChangeGasCap*1000)/1000


cap gen exclude=0
replace exclude=1 if Country=="DE"
replace exclude=1 if Country=="PL"


cap gen relief=-totalBurdenCap
graph bar Carbon_Revenue totalBurdenTax relief, over(Country) ytitle("Euros (Thousands)")  intensity(60) legend(label(1 "Revenue from 12.18 EUR/tonne Carbon Tax") label(2 "Burden from 12.18 EUR/tonne Carbon Tax") label(3 "Relief from 180 EUR/MWh Gas Cap") ring(1) position(6)) name(Rev,replace) asyvars bar(1,color(cranberry*0.6)) bar(2,color(edkblue*0.8)) bar(2,color(emerald*0.7)) title("B)",position(11)  size(*1.5))

//replace carb_revenue_norm=Carbon_Revenue/avg_load
//graph bar carb_revenue_norm, over(Country) ytitle("Revenue from 5.85 Euro Carbon Tax per MWh")  intensity(60) name(Rev,replace) title("C)",position(11)  size(*1.5))

graph combine PriceChange  Rev EmissionsChange  Total,altshrink


*compare the electricity price differences, but also the revenues generated--how?
*passthrough of country revenues to carbon price? (So given X increase in carbon price we know Y increase in revenue. Y should then be >= the difference in price from the gas cap?)
*revenue then divided by population for subsisdy per country? to compare with electricity price increase?

import excel "/Users/ZMarmarelis/Downloads/emission-spot-primary-market-auction-report-2021-data-4.xlsx", sheet("Primary Market Auction") firstrow
use ets_auctions
gen rev_pass=.
gen n=_n

//gen price= AuctionPricetCO2*884/2204
//(300 kgCo2/MWh*100t)
*or just 
*from https://www.epa.gov/energy/greenhouse-gases-equivalencies-calculator-calculations-and-references


reg  Co2_BG price
replace rev_pass=_b[price] if n==1
reg  Co2_CZ price
replace rev_pass=_b[price] if n==2
reg  Co2_DE price
replace rev_pass=_b[price] if n==3
reg  Co2_DK price 
replace rev_pass=_b[price] if n==4
reg  Co2_ES price 
replace rev_pass=_b[price] if n==5
reg  Co2_FI price 
replace rev_pass=_b[price] if n==6
reg  Co2_GR price 
replace rev_pass=_b[price] if n==7
reg  Co2_HR price
replace rev_pass=_b[price] if n==8
reg  Co2_HU price 
replace rev_pass=_b[price] if n==9
reg  Co2_IT price 
replace rev_pass=_b[price] if n==10
reg  Co2_NL price 
replace rev_pass=_b[price] if n==11
reg  Co2_PL price 
replace rev_pass=_b[price] if n==12
reg  Co2_RO price, nocons
replace rev_pass=_b[price] if n==13


*in fig4
*avg_emissions factor instead of 300 i.e. (300*1000/1000000), or just multiply by 0.3?
replace rev2= rev_pass
*multiply rev_pass by avg load to get Euros? Multiply by carbon tax, whatever that is actually 
replace Carbon_Revenue=5.85*rev_pass*avg_load


foreach y in "BG" "CZ" "DE" "DK" "ES" "FI" "GR""HR" "HU" "IT" "NL" "PL" "RO" {
	//cap gen F_`y'=Co_`y'/TotalRevenue
	//cap gen R_`y'= 1337747 * F_`y' 
	cap gen Co2_`y'=Co_`y'*`y'_LE

}
replace R_DE=  1025506 
replace R_PL=  2410488 


*compare specification
graph bar  marginal_effect marginal_effect2 ,over(country) yvaroptions(relabel(1 "Previous specification" 2 "Month FE and IRE"))


*****Other Scenarios******
*Carbon price if it is capped at 80 (Cheaper coal so higher relative price so more coal CF/emissions)
gen carbon_capped=price_carbon 
replace carbon_capped=80 if price_carbon>80
replace gas_carbon_capped=price_gas+carbon_capped*0.37*0.3
replace coal_carboncapped=price_usd_to_eur*price_coal_tonne/8.14+carbon_capped*0.3
replace rel_carboncapped=gas_carbon_capped/coal_carboncapped
replace rel_carboncapped2=rel_carboncapped^2

sum rel_carboncapped rel_testN if year==2022

*Under frozen carbon price in 2022
replace excess_carboncap=marginal_effect2*max_coal2022*(2.399946-2.364759)

tabstat excess_carboncap,by(country)

*Relative price if 50 euro carbon tax added
replace rel_carbontax50=(price_gas+price_carbon*0.37*0.3+50*0.37*0.3)/(coal_p+50*0.3+price_carbon*0.3)

sum rel_carbontax50 rel_testN if year==2022
*DECREASE GEN
replace excess_carbontax50=-marginal_effect2*max_coal2022*(2.364759-1.959939)




cap gen gas_p_CC=price_gas+price_carbon*0.37*0.3
replace rel_price_change=gas_carbon_capped-gas_p_CC
replace change_electricityPriceCarbonCap=(rel_price_change*passthrough)


replace rel_price_change=50*emissions_fac
replace change_PriceCarbonTax50=(rel_price_change*passthrough)*0.37

tabstat change_electricityPriceCarbonCap change_PriceCarbonTax50 if year==2022,by(country)


*multiply this PRICE change by the elasticity estimate, in MWh
gen change_electricityGenCarbonCap=change_electricityPriceCarbonCap/avg_electricity*elasticity*avg_load*1000
gen change_electricityGenCarbonTax50=change_PriceCarbonTax50/avg_electricity*elasticity*avg_load*1000

tabstat change_electricityGenCarbonCap change_electricityGenCarbonTax50 if year==2022,by(country)

gen change_emissionsCarbonCap=change_electricityGenCarbonCap*emissions_fac*24*365/1000
gen change_emissionsCarbonTax50=change_electricityGenCarbonTax50*emissions_fac*24*365/1000

*units? KILOTONNES/YEAR
tabstat change_emissionsCarbonCap change_emissionsCarbonTax50 sub_emissions_yearCarbonCap sub_emissions_yearCarbonTax50 if year==2022,by(country)


*emissions in mega tonne CO2 per year or kilotonnes (multiply by 1000)?? 
gen substitution_emissionsCarbonCap=(excess_carboncap*(coal_avg/avg_y_coal_lignite)*830)+(excess_carboncap*(lignite_avg/avg_y_coal_lignite)*1100)
gen sub_emissions_yearCarbonCap=substitution_emissionsCarbonCap*24*365/1000000
tabstat sub_emissions_yearCarbonCap,by(country)


gen sub_emissionsCarbonTax50=(excess_carbontax50*(coal_avg/avg_y_coal_lignite)*830)+(excess_carbontax50*(lignite_avg/avg_y_coal_lignite)*1100)
gen sub_emissions_yearCarbonTax50=sub_emissionsCarbonTax50*24*365/1000000
tabstat sub_emissions_yearCarbonTax50,by(country)


gen Carbon_Revenue50=50*avg_load*1000/emissions_fac/1000
gen Carbon_RevenueCarbonCap=(carbon_capped-price_carbon)*avg_load*1000/emissions_fac/1000



putexcel set Fig5, replace

putexcel A1 = "Country"
putexcel B1= "Price Change Carbon Cap" 
putexcel C1= "Price Change Tax 50" 
putexcel D1="Emissions factor"
putexcel E1="Emissions Change Carbon Cap"
putexcel F1="Emissions Change CarbonTax50"
putexcel G1="Sub Carbon Cap"
putexcel H1="Sub Carbon Tax50"
putexcel I1="RevCap"
putexcel J1="Rev50"





*no IE
local myrow = 2
foreach y in "BG" "CZ" "DE" "DK" "ES" "FI" "GR" "HR" "HU" "IT" "NL" "PL" "RO" {

	putexcel A`myrow' = "`y'"
	tabstat  change_electricityPriceCarbonCap if country=="`y'" &year==2022,save
	putexcel B`myrow' = matrix(r(StatTotal))
	tabstat  change_PriceCarbonTax50 if country=="`y'"  &year==2022,save
	putexcel C`myrow' = matrix(r(StatTotal))
	tabstat  emissions_fac if country=="`y'"  &year==2022,save
	putexcel D`myrow' = matrix(r(StatTotal))
	tabstat  change_emissionsCarbonCap if country=="`y'"  &year==2022,save
	putexcel E`myrow' = matrix(r(StatTotal))
	tabstat  change_emissionsCarbonTax50 if country=="`y'"  &year==2022,save
	putexcel F`myrow' = matrix(r(StatTotal))
	tabstat sub_emissions_yearCarbonCap if country=="`y'"  &year==2022,save
	putexcel G`myrow' = matrix(r(StatTotal))
	tabstat sub_emissions_yearCarbonTax50 if country=="`y'"  &year==2022,save
	putexcel H`myrow' = matrix(r(StatTotal))
	tabstat Carbon_RevenueCarbonCap if country=="`y'"  &year==2022,save
	putexcel I`myrow' = matrix(r(StatTotal))
	tabstat Carbon_Revenue50 if country=="`y'"  &year==2022,save
	putexcel J`myrow' = matrix(r(StatTotal))


	local myrow = `myrow' + 1
}

import excel "/Users/ZMarmarelis/Downloads/Fig5.xlsx", sheet("Sheet1") firstrow clear


use Fig5_ukraine

graph bar PriceChangeCarbonCap,over(Country) ytitle("2022 Wholesale Electricity Price Change (EUR/MWh) ",size(*1.2)) bar(1, color(green)) intensity(50) name(PriceChangeCC,replace) title("D)",position(11) size(*1.5))

graph bar PriceChangeTax50 ,over(Country)  ytitle("2022 Wholesale Electricity Price Change (EUR/MWh)",size(*1.2)) bar(1, color(green)) intensity(50) name(PriceChange50,replace) title("A)",position(11) size(*1.5))

graph bar EmissionsChangeCarbonCap ,over(Country) ytitle("Output Effect Emission Change (Ktonnes CO2/Year) ",size(*1.2))  bar(1,color(emerald*0.7)) name(EmissionsChangeCC,replace) title("B)		 80 EUR/tonne Carbon Cap",position(11)  size(*1.3))

graph bar EmissionsChangeCarbonTax50 ,over(Country) ytitle("Output Effect Emission Change (Ktonnes CO2/Year) ",size(*1.2))  bar(1,color(emerald*0.7)) name(EmissionsChange50,replace) title("A)   	 50 EUR/tonne Additional Carbon Tax",position(11)  size(*1.3))


graph bar SubCarbonTax50 ,over(Country) ytitle("Substitution Effect Emission Change (Ktonnes CO2/Year) ",size(*1.2))  bar(1,color(maroon*0.7)) name(Sub50,replace) title("C)",position(11)  size(*1.3))

graph bar SubCarbonCap ,over(Country) ytitle("Substitution Effect Emission Change (Ktonnes CO2/Year) ",size(*1.2))  bar(1,color(maroon*0.7)) name(Subcap,replace) title("D)",position(11)  size(*1.3))



graph bar RevCap totalBurdenCCap, over(Country) ytitle("Euros (Thousands)",size(*1.2))  intensity(60) legend(label(1 "Revenue from 80 EUR/tonne Carbon Cap") label(2 "Relief from 80 EUR/tonne Carbon Cap")ring(1) position(6)) name(RevCC,replace) asyvars bar(1,color(cranberry*0.6)) bar(2,color(edkblue*0.8)) title("E)",position(11)  size(*1.5))

graph bar Rev50 totalBurdenTax50, over(Country) ytitle("Euros (Thousands)",size(*1.2))  intensity(60) legend(label(1 "Revenue from 50 EUR/tonne Carbon Tax") label(2 "Burden from 50 EUR/tonne Carbon Tax")ring(1) position(6)) name(Rev50,replace) asyvars bar(1,color(cranberry*0.6)) bar(2,color(edkblue*0.8)) title("B)",position(11)  size(*1.5))


cap gen total_emissionsCCap= EmissionsChangeCarbonCap+SubCarbonCap
cap gen total_emissionsTax50=EmissionsChangeCarbonTax50+SubCarbonTax50

cap gen totalBurdenTax50=(avg_load*PriceChangeTax50*1000)/1000
cap gen totalBurdenCCap=(avg_load*PriceChangeCarbonCap*1000)/1000


graph bar total_emissionsCCap ,over(Country) ytitle("Emissions Change (Ktonnes CO2/Year)", size(*1.2)) bar(1,color(khaki))  intensity(50) name(TotalCC,replace) title("F)",position(11)  size(*1.5))

graph bar total_emissionsTax50 ,over(Country) ytitle("Emissions Change (Ktonnes CO2/Year)", size(*1.2)) bar(1,color(khaki))  intensity(50) name(Total50,replace) title("C)",position(11)  size(*1.5))

//graph bar EmissionsChangeCarbonCap EmissionsChangeCarbonTax50 ,over(Country)  legend( label(1 "180 EUR/MWh Natural Gas Cap") label(2 "Equivalent (12.18 EUR/tonne) Carbon Tax") ring(1) position(6)) ytitle("Output Effect Emission Change (Ktonnes CO2/Year)",size(*0.88))  asyvars bar(2,color(purple)) bar(1,color(emerald)) name(EmissionsChange,replace) title("B)",position(11)  size(*1.5))

//graph bar total_emissionsCCap total_emissionsTax50 ,over(Country) legend( label(1 "80 EUR/tonne Carbon Cap") label(2 "50 EUR/tonne Carbon Tax") ring(1) position(6))  ytitle("Emissions Change (Ktonnes CO2/Year)") asyvars bar(2,color(khaki)) bar(1,color(ebblue)) intensity(50) name(Total,replace) title("D)",position(11)  size(*1.5))

graph combine EmissionsChange50 EmissionsChangeCC Sub50 Subcap , altshrink  name("Effects",replace)
graph export Emissions_effects_SI.jpg, quality(100) replace

graph combine PriceChangeCC  RevCC  TotalCC,altshrink name(CarbonCap,replace) title("80 EUR/tonne Carbon Cap",size(*1.15)) rows(1)

graph combine PriceChange50 Rev50  Total50,altshrink name(Tax50,replace) title("50 EUR/tonne Additional Carbon Tax",size(*1.15)) rows(1)

graph combine Tax50 CarbonCap, name(Fig4_n,replace) rows(2) altshrink
graph export Fig4_n.jpg, quality(100) replace


*Fig 2_E esimate emissions under high/avg/low gas future prices for 2023
use futures_gascoal
gen rel_lowG=(84.89+80*0.37*0.3)/(27.95+80*0.3)
gen rel_avgG=(119.96+80*0.37*0.3)/(23.71+80*0.3)
gen rel_highG=(151.91+80*0.37*0.3)/(20.26+80*0.3)


use "/Users/ZMarmarelis/Downloads/ukraine_17b.dta"

gen lowG_F=.
gen avgG_F=.
gen highG_F=.

foreach y in "BG" "CZ" "DE" "DK" "ES" "FI" "HR" "HU" "IT" "IE" "NL" "PL" "RO" {
	reg  cf_coal2 c.rel_testN##c.rel_testN##c.rel_testN ire load load_sq i.hour i.dow i.month if sample==1 & country=="`y'",cl(dt)
	margins, at(rel_testN= 1.805) post
	replace lowG_F=_b[_cons] if country=="`y'"
	reg  cf_coal2 c.rel_testN##c.rel_testN##c.rel_testN ire load load_sq i.hour i.dow i.month if sample==1 & country=="`y'",cl(dt)
	margins, at(rel_testN= 2.7004) post 
	replace avgG_F=_b[_cons] if country=="`y'"
	reg  cf_coal2 c.rel_testN##c.rel_testN##c.rel_testN ire load load_sq i.hour i.dow i.month if sample==1 & country=="`y'",cl(dt)
	margins, at(rel_testN= 3.63285) post 
	replace highG_F=_b[_cons] if country=="`y'"
}
reg  cf_coal2 c.rel_testN##c.rel_testN##c.rel_testN ire load load_sq i.hour i.dow if sample==1 & country=="GR",cl(dt)
margins, at(rel_testN= 1.805) post
replace lowG_F=_b[_cons] if country=="GR"
reg  cf_coal2 c.rel_testN##c.rel_testN##c.rel_testN ire load load_sq i.hour i.dow if sample==1 & country=="GR",cl(dt)
margins, at(rel_testN= 2.7004) post 
replace avgG_F=_b[_cons] if country=="GR"
reg  cf_coal2 c.rel_testN##c.rel_testN##c.rel_testN ire load load_sq i.hour i.dow if sample==1 & country=="GR",cl(dt)
margins, at(rel_testN= 3.63285) post 
replace highG_F=_b[_cons] if country=="GR"


*The other way.. why are they different?
gen lowG_F2=marginal_effect2*1.805
gen avgG_F2=marginal_effect2*2.7004
gen highG_F2=marginal_effect2*3.63285

*which ones to use from above?

gen coal_emissionsHistoric=(y_coal*0.830+y_lignite*1.1) 


replace lowG_F_emissions=((coal_avg/avg_y_coal_lignite)*max_coal2022*lowG_F*0.830+(y_lignite/avg_y_coal_lignite)*max_coal2022*lowG_F*1.100)/1000000 *24*365
replace avgG_F_emissions=((coal_avg/avg_y_coal_lignite)*max_coal2022*avgG_F*0.830+(y_lignite/avg_y_coal_lignite)*max_coal2022*avgG_F*1.100)/1000000 *24*365
replace highG_F_emissions=((coal_avg/avg_y_coal_lignite)*max_coal2022*highG_F*0.830+(y_lignite/avg_y_coal_lignite)*max_coal2022*highG_F*1.100)/1000000 *24*365

tabstat lowG_F_emissions avgG_F_emissions highG_F_emissions max_coal2022,by(country)  

tabstat lowG_F avgG_F highG_F max_coal2022,by(country)

*collapse for sum? 


reg  cf_coal2 c.rel_testN##c.rel_testN##c.rel_testN ire load load_sq i.hour i.dow i.month if sample==1 & country=="DE",cl(dt)
margins, at(rel_testN=(0.7(0.1)4)) post
marginsplot, recast(connected) 




**Fig 2E (now in EDF)

use fig2_e
graph hbar e_2013 e_2016 e_2019 low avg high e_2030,showyvars legend(off)

set scheme white_tableau
graph hbar em,over(years) intensity(50) xalternate bargap(40)  bar(1,color(gold*0.9))  bar(2,color(gold*0.9))  bar(3,color(gold*0.9))  bar(4,color(gold*0.9))  bar(5,color(midgreen*0.7))  bar(6,color(midgreen*0.7))  bar(7,color(midgreen*0.7))  bar(8,color(purple*0.8)) asyvars showyvars legend(off) ysc(r(100 600)) ytitle("Mtonnes CO2 Emissions") ylabel(,labsize(*1.3) nogrid) 


graph hbar percChange if !missing(percChange),over(years)  ytitle("Percent Change Mtonnes CO2 Compared to 2018-2022 Baseline (%)") 


*********Tables for SI/EDF


*Main
foreach y in "BG" "CZ" "DE" "DK" "ES" "FI" "GR" "HR" "HU" "IT" "IE" "NL" "PL" "RO" {

	if "`y'"=="GR"{
		reg  cf_coal2 rel_testN rel_testN2 rel_testN3 ire load load_sq i.hour i.dow if sample==1 & country=="GR",cl(dt)
		outreg2  using "mainspec.doc",  append addtext(Month FE, YES, Hour FE, YES, Day of Week FE, YES) keep(rel_testN rel_testN2 rel_testN3 ire load load_sq) label ctitle(`y') nocons bdec(3) sdec(3) 
	}
	else{
		if "`y'"=="BG"{
			reg  cf_coal2 rel_testN rel_testN2 rel_testN3 ire load load_sq i.hour i.dow i.month if sample==1 & country=="`y'",cl(dt)
			outreg2  using "mainspec.doc",  replace addtext(Month FE, YES, Hour FE, YES, Day of Week FE, YES) keep(rel_testN rel_testN2 rel_testN3 ire load load_sq) label ctitle(`y') nocons bdec(3) sdec(3) 
		}
		else{
			reg  cf_coal2 rel_testN rel_testN2 rel_testN3 ire load load_sq i.hour i.dow i.month if sample==1 & country=="`y'",cl(dt)
			outreg2  using "mainspec.doc",  append addtext(Month FE, YES, Hour FE, YES, Day of Week FE, YES) keep(rel_testN rel_testN2 rel_testN3 ire load load_sq) label ctitle(`y') nocons bdec(3) sdec(3) 

		}
		// 			sum rel_testN if sample==1
		// 			local meanss = r(mean)
		// 			sum rel_testN2 if sample==1
		// 			local meanss2=r(mean)
		// 			nlcom (marg: 3*_b[rel_testN3]* `meanss2' + 2 * `meanss' * _b[rel_testN2] + _b[rel_testN]),post
		// 			//local mar=_b[marg]
		// 			replace marginal_effect2 = _b[marg] if country=="`y'"
		// 			replace se_marginal_effect2 = _se[marg] if country=="`y'"

	}
}

cap gen  marginal_effectNM=.
cap gen se_marginal_effectNM=.
foreach y in "BG" "CZ" "DE" "DK" "ES" "FI" "GR" "HR" "HU" "IT" "IE" "NL" "PL" "RO" {

	if "`y'"=="GR"{
		reg  cf_coal2 rel_testN rel_testN2 rel_testN3 ire load load_sq i.hour i.dow if sample==1 & country=="GR",cl(dt)
		outreg2  using "noMonth.xls",  append addtext(Month FE, NO, Hour FE, YES, Day of Week FE, YES) keep(rel_testN rel_testN2 rel_testN3 ire load load_sq) label ctitle(`y') nocons bdec(2) sdec(2)
	}
	else{
		if "`y'"=="BG"{
			reg  cf_coal2 rel_testN rel_testN2 rel_testN3 ire load load_sq i.hour i.dow  if sample==1 & country=="`y'",cl(dt)
			outreg2  using "noMonth.xls",  replace addtext(Month FE, NO, Hour FE, YES, Day of Week FE, YES) keep(rel_testN rel_testN2  rel_testN3 ire load load_sq) label ctitle(`y') nocons bdec(2) sdec(2)
		}
		else{
			reg  cf_coal2 rel_testN rel_testN2 rel_testN3 ire load load_sq i.hour i.dow if sample==1 & country=="`y'",cl(dt)
			outreg2  using "noMonth.xls",  append addtext(Month FE, NO, Hour FE, YES, Day of Week FE, YES) keep(rel_testN rel_testN2 rel_testN3 ire load load_sq) label ctitle(`y') nocons bdec(2) sdec(2)
		}
	}
	sum rel_testN if sample==1
	local meanss = r(mean)
	sum rel_testN2 if sample==1
	local meanss2=r(mean)
	nlcom (marg: 3*_b[rel_testN3]* `meanss2' + 2 * `meanss' * _b[rel_testN2] + _b[rel_testN]),post
	//local mar=_b[marg]
	replace marginal_effectNM = _b[marg] if country=="`y'"
	replace se_marginal_effectNM = _se[marg] if country=="`y'"
}


cap gen  marginal_effectnoIRE=.
cap gen se_marginal_effectnoIRE=.
foreach y in "BG" "CZ" "DE" "DK" "ES" "FI" "GR" "HR" "HU" "IT" "IE" "NL" "PL" "RO" {

	if "`y'"=="GR"{
		reg  cf_coal2 rel_testN rel_testN2 rel_testN3 load load_sq i.hour i.dow i.month if sample==1 & country=="GR",cl(dt)
		outreg2  using "noIRE.xls",  append addtext(Month FE, NO, Hour FE, YES, Day of Week FE, YES) keep(rel_testN rel_testN2 rel_testN3 load load_sq) label ctitle(`y') nocons bdec(2) sdec(2)
	}
	else{
		if "`y'"=="BG"{
			reg  cf_coal2 rel_testN rel_testN2 rel_testN3 load load_sq i.hour i.dow i.month  if sample==1 & country=="`y'",cl(dt)
			outreg2  using "noIRE.xls",  replace addtext(Month FE, NO, Hour FE, YES, Day of Week FE, YES) keep(rel_testN rel_testN2 rel_testN3 load load_sq) label ctitle(`y') nocons bdec(2) sdec(2)
		}
		else{
			reg  cf_coal2 rel_testN rel_testN2 rel_testN3  load load_sq i.hour i.dow i.month if sample==1 & country=="`y'",cl(dt)
			outreg2  using "noIRE.xls",  append addtext(Month FE, NO, Hour FE, YES, Day of Week FE, YES) keep(rel_testN rel_testN2 rel_testN3 load load_sq) label ctitle(`y') nocons bdec(2) sdec(2)
		}
	}

	sum rel_testN if sample==1
	local meanss = r(mean)
	sum rel_testN2 if sample==1
	local meanss2=r(mean)
	nlcom (marg: 3*_b[rel_testN3]* `meanss2' + 2 * `meanss' * _b[rel_testN2] + _b[rel_testN]),post
	//local mar=_b[marg]
	replace marginal_effectnoIRE = _b[marg] if country=="`y'"
	replace se_marginal_effectnoIRE = _se[marg] if country=="`y'"
}


cap gen  marginal_effectNuc=.
cap gen se_marginal_effectNuc=.
foreach y in "BG" "CZ" "DE" "DK" "ES" "FI" "GR" "HR" "HU" "IT" "IE" "NL" "PL" "RO" {

	if "`y'"=="GR"{
		reg  cf_coal2 rel_testN rel_testN2 rel_testN3 ire y_nuclear load load_sq i.hour i.dow i.month if sample==1 & country=="GR",cl(dt)
		outreg2  using "NucControl.xls",  append addtext(Month FE, NO, Hour FE, YES, Day of Week FE, YES) keep(rel_testN rel_testN2 rel_testN3 ire y_nuclear load load_sq) label ctitle(`y') nocons bdec(2) sdec(2)
	}
	else{
		if "`y'"=="BG"{
			reg  cf_coal2 rel_testN rel_testN2 rel_testN3 ire y_nuclear load load_sq i.hour i.dow i.month  if sample==1 & country=="`y'",cl(dt)
			outreg2  using "NucControl.xls",  replace addtext(Month FE, NO, Hour FE, YES, Day of Week FE, YES) keep(rel_testN rel_testN2 rel_testN3 ire y_nuclear load load_sq) label ctitle(`y') nocons bdec(2) sdec(2)
		}
		else{
			reg  cf_coal2 rel_testN rel_testN2 rel_testN3 ire y_nuclear  load load_sq i.hour i.dow i.month if sample==1 & country=="`y'",cl(dt)
			outreg2  using "NucControl.xls",  append addtext(Month FE, NO, Hour FE, YES, Day of Week FE, YES) keep(rel_testN rel_testN2 rel_testN3 ire y_nuclear  load load_sq) label ctitle(`y') nocons bdec(2) sdec(2)
		}
	}

	sum rel_testN if sample==1
	local meanss = r(mean)
	sum rel_testN2 if sample==1
	local meanss2=r(mean)
	nlcom (marg: 3*_b[rel_testN3]* `meanss2' + 2 * `meanss' * _b[rel_testN2] + _b[rel_testN]),post
	//local mar=_b[marg]
	replace marginal_effectNuc = _b[marg] if country=="`y'"
	replace se_marginal_effectNuc = _se[marg] if country=="`y'"
}


cap gen  marginal_effectLog=.
cap gen se_marginal_effectLog=.
foreach y in "BG" "CZ" "DE" "DK" "ES" "FI" "GR" "HR" "HU" "IT" "IE" "NL" "PL" "RO" {

	if "`y'"=="GR"{
		reg  ln_cfcoal ln_rel ln_rel2 ln_rel3 ire  load load_sq i.hour i.dow i.month if sample==1 & country=="GR",cl(dt)
		outreg2  using "LogsSpec.xls",  append addtext(Month FE, NO, Hour FE, YES, Day of Week FE, YES) keep(ln_rel ln_rel2 ln_rel3  ire  load load_sq) label ctitle(`y') nocons bdec(2) sdec(2)
	}
	else{
		if "`y'"=="BG"{
			reg  ln_cfcoal ln_rel ln_rel2 ln_rel3 ire  load load_sq i.hour i.dow i.month  if sample==1 & country=="`y'",cl(dt)
			outreg2  using "LogsSpec.xls",  replace addtext(Month FE, NO, Hour FE, YES, Day of Week FE, YES) keep(ln_rel ln_rel2 ln_rel3  ire load load_sq) label ctitle(`y') nocons bdec(2) sdec(2)
		}
		else{
			reg  ln_cfcoal ln_rel ln_rel2 ln_rel3  ire   load load_sq i.hour i.dow i.month if sample==1 & country=="`y'",cl(dt)
			outreg2  using "LogsSpec.xls",  append addtext(Month FE, NO, Hour FE, YES, Day of Week FE, YES) keep(ln_rel ln_rel2 ln_rel3  ire  load load_sq) label ctitle(`y') nocons bdec(2) sdec(2)
		}
	}
	sum ln_rel if sample==1
	local meanss = r(mean)
	sum ln_rel2 if sample==1
	local meanss2=r(mean)
	nlcom (marg: 3*_b[ln_rel]* `meanss2' + 2 * `meanss' * _b[ln_rel2] + _b[ln_rel3]),post
	//local mar=_b[marg]
	replace marginal_effectLog = _b[marg] if country=="`y'"
	replace se_marginal_effectLog = _se[marg] if country=="`y'"
}


putexcel set marginal_SI2, replace

putexcel A1 = "Country"
putexcel B1= "MarginalNoMonth" 
putexcel C1= "SE1" 
putexcel D1= "MarginalnoIRE" 
putexcel E1= "SE2"
putexcel F1= "MarginalNuc" 
putexcel G1= "SE3" 
putexcel H1= "MarginalLog" 
putexcel I1= "SE4" 

local myrow = 2
foreach y in "BG" "CZ" "DE" "DK" "ES" "FI" "GR" "HR" "HU" "IT" "IE" "NL" "PL" "RO" {

	putexcel A`myrow' = "`y'"
	tabstat marginal_effectNM if country=="`y'",save
	putexcel B`myrow' = matrix(r(StatTotal))
	tabstat se_marginal_effectNM if country=="`y'",save
	putexcel C`myrow' = matrix(r(StatTotal))
	tabstat marginal_effectnoIRE if country=="`y'",save
	putexcel D`myrow' = matrix(r(StatTotal))
	tabstat se_marginal_effectnoIRE if country=="`y'",save
	putexcel E`myrow' = matrix(r(StatTotal))
	tabstat marginal_effectNuc if country=="`y'",save
	putexcel F`myrow' = matrix(r(StatTotal))
	tabstat se_marginal_effectNuc if country=="`y'",save
	putexcel G`myrow' = matrix(r(StatTotal))
	tabstat marginal_effectLog if country=="`y'",save
	putexcel H`myrow' = matrix(r(StatTotal))
	tabstat se_marginal_effectLog if country=="`y'",save
	putexcel I`myrow' = matrix(r(StatTotal))

	local myrow = `myrow' + 1
}


foreach y in "BG" "CZ" "DE" "DK" "ES" "FI" "HR" "HU" "IT" "IE" "NL" "PL" "RO" {
	reg  cf_coal2 c.rel_testN##c.rel_testN##c.rel_testN ire load load_sq i.hour i.dow i.month if sample==1 & country=="`y'",cl(dt)
	margins, at(rel_test=(1(0.05)4)) post
	marginsplot, recast(connected) noci name(marg`y',replace) xtitle("Relative Price") ytitle("Predicted Coal Capacity Factor") title(`y') xline(1.25 1.878 2.36 1.805 2.7 3.63) 
	//text(0.5 1.25 "Jan-March 2021" 0.48 1.878 "April 2021-May 2022" 0.5 2.36 "Jan-Dec 2022" 0.46 1.805 "Low Futures Price 2023" 0.46 2.7 "Mean Futures Price 2023" 0.5 3.63 "High Futures Price 2023", size(*0.5) box place(c)   margin(l+4 t+1 b+1) width(20) just(c)) 
	//graph export `y'_margins.jpg, quality(100)

}
reg  cf_coal2 c.rel_testN##c.rel_testN##c.rel_testN ire load load_sq i.hour i.dow if sample==1 & country=="GR",cl(dt)
margins, at(rel_test=(1(0.05)4)) post
marginsplot, recast(connected) noci name(margGR,replace) xtitle("Relative Price") ytitle("Predicted Coal Factor") title("GR") xline(1.25 1.878 2.36 1.805 2.7 3.63)
//text(0.5 1.25 "Jan-March 2021" 0.48 1.878 "April 2021-May 2022" 0.5 2.36 "Jan-Dec 2022" 0.46 1.805 "Low Futures Price 2023" 0.46 2.7 "Mean Futures Price 2023" 0.5 3.63 "High Futures Price 2023", size(*0.5) box place(c)   margin(l+4 t+1 b+1) width(20) just(c)) 
//graph export GR_margins.jpg, quality(100) replace

graph combine margBG margCZ margDE margDK margGR margES margIT margNL margPL, altshrink name(marginsC,replace)


// 	1.252849 // Jan-March 2021
// 	1.878083 //Sample
// 	2.364759  // 2022
// 	1.805 // Low Price
// 	2.7 //Avg price
// 	3.63  //High price


use emissions_long
graph bar emissions, over(year) by(country,yrescale) ytitle("Mtonnes CO2") legend(off) intensity(50) bar(1,color(purple*0.5))  bar(2,color(purple*0.5))  bar(3,color(purple*0.5))  bar(4,color(purple*0.5))  bar(5,color(purple*0.5))  bar(6,color(dkorange*0.7)) asyvars showyvars 


foreach y in "DE" "ES" "NL" "IT" "PL"  {
 	reg  cf_coal2 c.rel_testN##c.rel_testN##c.rel_testN if sample==1 & country=="`y'",vce(robust)
	margins, dydx(rel_test)
	local a=r(table)[rownumb(r(table),"b"),1]
	 //reg  cf_coal2 c.rel_testN##c.rel_testN##c.rel_testN if sample==1 & country=="`y'",vce(robust)
	outreg2 using `y'SI_spec.doc,replace se label adjr2  bdec(2)  keep(rel_testN c.rel_testN#c.rel_testN c.rel_testN#c.rel_testN#c.rel_testN) addtext(Month FE,NO , Hour FE, NO, Day-of-Week FE, NO, Clustered SE, NO) title(`y') nocons addstat(Marginal Effect, `a') ctitle(" ")
	reg  cf_coal2 c.rel_testN##c.rel_testN##c.rel_testN load load_sq if sample==1 & country=="`y'",vce(robust)
	margins, dydx(rel_test)
	local a=r(table)[rownumb(r(table),"b"),1]
	outreg2 using `y'SI_spec.doc,append se label adjr2  bdec(2)  keep(rel_testN c.rel_testN#c.rel_testN c.rel_testN#c.rel_testN#c.rel_testN load load_sq) addtext(Month FE, NO , Hour FE, NO, Day-of-Week FE, NO, Clustered SE, NO) title(`y') nocons  addstat(Marginal Effect, `a') ctitle(" ")
	reg  cf_coal2 c.rel_testN##c.rel_testN##c.rel_testN ire load load_sq if sample==1 & country=="`y'",vce(robust)
	margins, dydx(rel_test)
	local a=r(table)[rownumb(r(table),"b"),1]
	outreg2 using `y'SI_spec.doc,append se label adjr2  bdec(2)  keep(rel_testN c.rel_testN#c.rel_testN c.rel_testN#c.rel_testN#c.rel_testN ire load load_sq) addtext(Month FE, NO , Hour FE, NO, Day-of-Week FE, NO, Clustered SE, NO) title(`y') nocons  addstat(Marginal Effect, `a') ctitle(" ")
	reg  cf_coal2 c.rel_testN##c.rel_testN##c.rel_testN ire load load_sq i.hour i.dow if sample==1 & country=="`y'",vce(robust)
	margins, dydx(rel_test)
	local a=r(table)[rownumb(r(table),"b"),1]
	outreg2 using `y'SI_spec.doc,append se label adjr2  bdec(2)  keep(rel_testN c.rel_testN#c.rel_testN c.rel_testN#c.rel_testN#c.rel_testN ire load load_sq) addtext(Month FE, NO , Hour FE, YES, Day-of-Week FE, YES, Clustered SE, NO) title(`y') nocons addstat(Marginal Effect, `a') ctitle(" ")
	reg  cf_coal2 c.rel_testN##c.rel_testN##c.rel_testN ire load load_sq i.month i.hour i.dow if sample==1 & country=="`y'",vce(robust)
	margins, dydx(rel_test)
	local a=r(table)[rownumb(r(table),"b"),1]
	outreg2 using `y'SI_spec.doc,append se label adjr2  bdec(2)  keep(rel_testN c.rel_testN#c.rel_testN c.rel_testN#c.rel_testN#c.rel_testN ire load load_sq) addtext(Month FE, YES , Hour FE, YES, Day-of-Week FE, YES, Clustered SE, NO) title(`y') nocons  addstat(Marginal Effect, `a') ctitle(" ")
	reg  cf_coal2 c.rel_testN##c.rel_testN##c.rel_testN ire load load_sq i.hour i.dow i.month if sample==1 & country=="`y'",cl(dt)
	margins, dydx(rel_test)
	local a=r(table)[rownumb(r(table),"b"),1]
	outreg2 using `y'SI_spec.doc,append se label adjr2  bdec(2)  keep(rel_testN c.rel_testN#c.rel_testN c.rel_testN#c.rel_testN#c.rel_testN ire load load_sq) addtext(Month FE,YES , Hour FE, YES, Day-of-Week FE, YES, Clustered SE, Day) title(`y') nocons addstat(Marginal Effect, `a') ctitle(" ")
}



tw line price_gas t if sample==1 | year==2022, yline(180) sort xlabel(, format(%tCMon-CCYY)) xtitle("") ytitle("Natural Gas Price (EUR/MWh)") lwidth(*1.4) lcolor(maroon*0.8) name(g,replace)
tw line price_carbon t if sample==1 | year==2022, yline(80) sort xlabel(, format(%tCMon-CCYY)) xtitle("") ytitle("Carbon price (EUR/ton CO2)") lwidth(*1.4) lcolor(dkorange*0.8) name(c,replace)
tw line rel_testN t if sample==1 | year==2022,sort xlabel(, format(%tCMon-CCYY)) xtitle("") lwidth(*1.4) lcolor(emerald*0.8) name(r,replace)
graph combine g c r, rows(3) altshrink


*Fig 3
tabstat total_emissionsTax total_emissionsCap,s(sum)
*Fig 4
tabstat total_emissionsTax50 total_emissionsCCap,s(sum)




putexcel set excess_coal_relative, replace

putexcel A1 = "Country"
putexcel B1= "Relative Emissions" //panel D
putexcel C1= "Relative Gen" ///panel C

local myrow = 2
foreach y in "BG" "CZ" "DE" "DK" "ES" "FI" "GR" "HR" "HU" "IT" "IE" "NL" "PL" "RO" {

	putexcel A`myrow' = "`y'"
	tabstat relative_emissions if country=="`y'",save
	putexcel B`myrow' = matrix(r(StatTotal))
	tabstat relative_gen if country=="`y'",save
	putexcel C`myrow' = matrix(r(StatTotal))
	local myrow = `myrow' + 1
}


