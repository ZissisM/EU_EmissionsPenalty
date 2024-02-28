use ukraine_17b


***Fig 3 / Counterfactuals ****

*gas price if gas cap at 180
gen gas_price_capped=price_gas



**This one!! Converted carbon price
gen gas_price_cappedN=price_gas
replace gas_price_cappedN=180 if price_gas>180
replace gas_price_cappedCN=gas_price_cappedN+price_carbon*0.3*0.37
gen rel_gascapN=gas_price_cappedCN/(price_usd_to_eur*price_coal_tonne/8.14+price_carbon*0.3)



*1.049069 for sample (vs 1.0584)
sum rel_test_gascap if sample==1
*1.40098 vs 1.351114 for 2022
sum rel_testN rel_test_gascapN if year==2022


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
*DECREASE in 2022 if cap was in place
*USE THIS
gen diff_2022CapN=( 2.364759-2.247722)*marginal_effect2*max_coal2022

**Using actual coal average generation, subtract the prediction under the cap 
egen avg_y_coal_lignite_2022=mean(y_coal_lignite) if year==2022, by(country)
egen max_coal2022=max(y_coal_lignite) if year==2022,by(country)




**Find equiavalent carbon price with same substitution effect as natural gas cap 
** needs to be done for 2022 and not sample
use prices_2022_ukraine
cap drop diff carbon_tax temp temp_mean
cap drop diff carbon_tax
gen diff = .
gen carbon_tax = .

local min_diff = 10
local optimal_tax = .
//forval i = 100(1)50000 {
forval i = 10000(1)200000 {
    local x = `i' / 1000
    quietly gen temp = (price_gas + `x'*0.37*0.3+price_carbon*0.37*0.3) / (coal_p + (price_carbon+`x')*0.3)
    quietly egen temp_mean = mean(temp)
	*1.049069 is the average price gas capped in sample  --  2.247722 is new price after carbon conevrsion
	// 1.252849 is the Jan-March 2021 price used in Fig 2.. the comparison used. (2.247722 is the actual one used below for 12.18)
    quietly replace diff = abs(temp_mean - 1.252849) 

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

//replace carbon_tax=12.18
replace carbon_tax=12.18
replace rel_test_carbonTax=(price_gas+price_carbon*0.37*0.3+carbon_tax*0.37*0.3)/(coal_p+carbon_tax*0.3+price_carbon*0.3)


*eliminate substitution
replace carbon_tax3=179.075
replace rel_test_carbonTax2=(price_gas+price_carbon*0.37*0.3+carbon_tax*0.37*0.3)/(coal_p+carbon_tax3*0.3+price_carbon*0.3)

//or 1.252849
sum rel_test_carbonTax2 if year==2022
*Same!




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


**change in PRICE 
egen avg_electricity=mean(electricity_prices) if year==2022,by(country)
egen avg_load=mean(load) if year==2022,by(country)

replace rel_price_change=change_gaspriceCap
replace change_electricityPriceGasCap=(rel_price_change*passthrough)
replace rel_price_change=change_carbonTax
replace change_electricityPriceCarbonTax=(rel_price_change*passthrough)*0.37

tabstat change_electricityPriceGasCap change_electricityPriceCarbonTax if year==2022,by(country)



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


*divide by 1000 to be in thousands euros
replace Carbon_Revenue=12.18*avg_load*1000/Averageemissionsfactor/1000


graph bar PriceChangeGasCap PriceChangeCarbonTax  ,over(Country)  legend( label(1 "180 EUR/MWh Natural Gas Cap") label(2 "Equivalent (12.18 EUR/tonne) Carbon Tax") ring(1) position(6)) ytitle("2022 Wholesale Electricity Price Change (EUR/MWh)",size(*0.88)) asyvars bar(2,color(maroon)) bar(1,color(green)) intensity(50) name(PriceChange,replace) title("C)",position(11) size(*1.5))

//tw bar EmissionsChangeGasCap EmissionsChangeCarbonTax sub, over(country_id) barw(0.4) barw(0.2) legend( label(1 "Output Effect: 180 EUR/MWh Natural Gas Cap ") label(2 "Output Effect: Equivalent (12.18 EUR/tonne) Carbon Tax") label(3 "Substitution Effect") ring(1) position(6)) ytitle("Emission Change (Ktonnes CO2/Year)",size(*0.88))  name(EmissionsChange,replace) title("B)",position(11)  size(*1.5)) || rcap EmissiosnChangeGasCapLow EmissiosnChangeGasCapHigh country_id || rcap  EmissiosnChangeCarbonTaxLow EmissiosnChangeCarbonTaxHigh country_id

//graph bar EmissionsChangeGasCap EmissionsChangeCarbonTax sub EmissiosnChangeGasCapHigh EmissiosnChangeCarbonTaxHigh  ,over(Country)  legend( label(1 "Output Effect: 180 EUR/MWh Natural Gas Cap ") label(2 "Output Effect: Equivalent (12.18 EUR/tonne) Carbon Tax") label(3 "Substitution Effect") label(4 "") label(5 "") ring(1) position(6)) ytitle("Emission Change (Ktonnes CO2/Year)",size(*0.88))  asyvars bar(2,color(purple)) bar(1,color(emerald)) bar(4,color(white))  bar(5,color(white)) intensity(50) name(EmissionsChange,replace) title("B)",position(11)  size(*1.5))

graph bar EmissionsChangeCarbonTax EmissiosnChangeCarbonTaxHigh EmissiosnChangeCarbonTaxLow ,over(Country)  legend( ring(1) position(6)) ytitle("Emission Change (Ktonnes CO2/Year)",size(*0.88))  asyvars bar(2,color(purple)) bar(1,color(emerald)) intensity(50) name(EmissionsChange,replace) title("B)",position(11)  size(*1.5))



graph bar total_emissionsCap total_emissionsTax ,over(Country) legend( label(1 "180 EUR/MWh Natural Gas Cap") label(2 "Equivalent (12.18 EUR/tonne) Carbon Tax") ring(1) position(6))  ytitle("Total Emissions Change (Ktonnes CO2/Year)") asyvars bar(2,color(khaki)) bar(1,color(ebblue)) intensity(50) name(Total,replace) title("A)",position(11)  size(*1.5))

graph bar Carbon_Revenue totalBurdenTax relief, over(Country) ytitle("Euros (Thousands)")  intensity(60) legend(label(1 "Revenue from 12.18 EUR/tonne Carbon Tax") label(2 "Burden from 12.18 EUR/tonne Carbon Tax") label(3 "Relief from 180 EUR/MWh Gas Cap") ring(1) position(6)) name(Rev,replace) asyvars bar(1,color(cranberry*0.6)) bar(2,color(edkblue*0.8)) bar(2,color(emerald*0.7)) title("D)",position(11)  size(*1.5))


*divide by 1000 to be in thousands
replace totalBurdenTax=(avg_load*PriceChangeCarbonTax*1000)/1000
replace totalBurdenCap=(avg_load*PriceChangeGasCap*1000)/1000


cap gen exclude=0
replace exclude=1 if Country=="DE"
replace exclude=1 if Country=="PL"


cap gen relief=-totalBurdenCap


graph combine   Total  EmissionsChange PriceChange Rev  ,altshrink

graph bar rev_dif,over(Country)   ytitle("Revenue difference (Euros in thousands)",size(*0.98))  bar(1,color(maroon)) intensity(50) name(rd,replace) title("",position(11) size(*1.5))



*compare the electricity price differences, but also the revenues generated
*passthrough of country revenues to carbon price? (So given X increase in carbon price we know Y increase in revenue. Y should then be >= the difference in price from the gas cap?)

