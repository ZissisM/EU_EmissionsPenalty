use ukraine_17b

*imported dataset has generations, electricity prices, gas prices and coal prices
* import delimited "/Users/ZMarmarelis/Desktop/Taraq_transfer/EU_workspace/data/ukraine/_17_3b_regression_cleanV3.csv", clear 

gen double t=clock(t,"YMDhms")
format t %tc


replace coal_test=(price_usd_to_eur*price_coal_tonne)/8.14
replace coal_p_c=price_usd_to_eur*price_coal_tonne/8.14+price_carbon
replace gas_p_c=price_gas+price_carbon*0.37


***NEW rel_price with CONVERTED CARBON PRICE
*This one
gen rel_testN= (price_gas+price_carbon*0.37*0.3)/(price_usd_to_eur*price_coal_tonne/8.14+price_carbon*0.3)
gen rel_testN2=rel_testN^2
gen rel_testN3=rel_testN^3
gen load_sq=load^2
*load and y_all_renewables was converted to GWh from MWh


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


**make distinction to greece to not include month FE because they look at previous month prices???
//foreach y in  "GR"  {
foreach y in "BG" "CZ" "DE" "DK" "ES" "FI" "GR" "HR" "HU" "IT" "IE" "NL" "PL" "RO" {
	*country
	reg  cf_coal2 rel_testN rel_testN2 rel_testN3 ire load load_sq i.hour i.dow i.month if sample==1 & country=="`y'",cl(dt)
	//GR has different time FE because of how their gas market works

	*pooled (can also do the cubics as c.rel_test##c.rel_test##c.rel_test)
	//reghdfe  cf_coal2 c.rel_testN##c.rel_testN##c.rel_testN  ire load load_sq if sample==1,absorb(panel_id dow hour month) cl(dt)
	//margins, dydx(rel_test) 

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



*Figure 1 panels*


egen mean_elec=mean(electricity_prices) if sample==1 & !missing(electricity_prices),by(t)
egen elec_ma=mean(mean_elec) if sample==1,by(date)


egen avg_co=mean(y_coal_lignite) if sample==1,by(t)
egen avg_coallig=mean(avg_co) if sample==1,by(date)

tw line avg_coallig t if sample==1,sort

tw line price_carbon dt if sample==1 & country=="GR", sort xlabel(#9, format(%tdMon-CCYY)) xtitle("") ytitle("Carbon price (EUR/ton CO2)",size(*1.2)) lwidth(*1.4) lcolor(emerald*0.8) name(c,replace) 

tw line price_coal dt if sample==1 & country=="GR", sort xlabel(#9, format(%tdMon-CCYY)) xtitle("") ytitle("Coal price (EUR/MWh)",size(*1.2)) lwidth(*1.4) lcolor(sienna*0.8) name(co,replace)

tw line elec_ma dt if sample==1, sort xlabel(#9, format(%tdMon-CCYY)) xtitle("") ytitle("Average Wholesale Electricity Price (EUR/MWh)",size(*1.2)) lwidth(*1.2) lcolor(dkorange*0.75) name(el,replace)

tw line avg_coallig dt if sample==1 & country=="GR", sort xlabel(#9, format(%tdMon-CCYY)) xtitle("") ytitle("Average Coal Generation (MWh)",size(*1.2)) lwidth(*1.2) lcolor(maroon*0.75) name(cos,replace)
