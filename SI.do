use ukraine_17b

**SI figures and tables and calculations


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




**SI Figure additional policy
***to eliminate ALL emissions and get to pre-crisis levels
replace rel_price_change=(carbon_tax3*emissions_fac)
*Price change
gen change_ePriceCarbonTax2=(rel_price_change*passthrough)*0.37
*electricity change
gen change_electricityGenCarbonTax2=change_ePriceCarbonTax2/avg_electricity*elasticity*avg_load*1000
*emissions change from electricity change/ output
gen change_emissionsCarbonTax2=change_electricityGenCarbonTax2*emissions_fac*24*365/1000

replace diff_2219=(2.364759-1.252849)*marginal_effect2*max_coal2022

replace substitution2=(diff_2219*(coal_avg/avg_y_coal_lignite)*830)+(diff_2219*(lignite_avg/avg_y_coal_lignite)*1100)
*Substitution
replace sub_emissions_year2=substitution2*24*365/1000000


gen RevC2=carbon_tax3*avg_load*1000/emissions_fac/1000
gen BurdenC2=(avg_load*change_ePriceCarbonTax2*1000)/1000

putexcel set Fig_179,replace

putexcel A1 = "Country"
putexcel B1= "Price Change Tax" 
putexcel C1= "Output" 
putexcel D1="Substitution"
putexcel E1="Rev"
putexcel F1="Burd"

*no IE
local myrow = 2
foreach y in "BG" "CZ" "DE" "DK" "ES" "FI" "GR" "HR" "HU" "IT" "NL" "PL" "RO" {

	putexcel A`myrow' = "`y'"
	tabstat  change_ePriceCarbonTax2 if country=="`y'" &year==2022,save
	putexcel B`myrow' = matrix(r(StatTotal))
	tabstat  change_emissionsCarbonTax2 if country=="`y'"  &year==2022,save
	putexcel C`myrow' = matrix(r(StatTotal))
	tabstat  sub_emissions_year2 if country=="`y'"  &year==2022,save
	putexcel D`myrow' = matrix(r(StatTotal))
	tabstat  RevC2 if country=="`y'"  &year==2022,save
	putexcel E`myrow' = matrix(r(StatTotal))
	tabstat  BurdenC2 if country=="`y'"  &year==2022,save
	putexcel F`myrow' = matrix(r(StatTotal))

	local myrow = `myrow' + 1
}

import excel "/Users/ZMarmarelis/Downloads/Fig_179.xlsx", sheet("Sheet1") firstrow clear

use Fig_suball

replace total_emissions=Substitution+Output

graph bar PriceChangeTax,over(Country)   ytitle("2022 Wholesale Electricity Price Change (EUR/MWh)",size(*0.98))  bar(1,color(green)) intensity(50) name(PriceChange,replace) title("C)",position(11) size(*1.5))

//replace Substitution=-Substitution
graph bar Output Substitution ,over(Country)  legend( ring(1) position(6)) ytitle("Emission Change (Ktonnes CO2/Year)",size(*0.98))  asyvars bar(2,color(purple*0.8)) bar(1,color(maroon)) intensity(50) name(EmissionsChange,replace) title("B)",position(11)  size(*1.5))  legend( label(1 "Output Effect") label(2 "Substitution Effect") ring(1) position(6))

graph bar total_emissions ,over(Country)  ytitle("Total Emissions Change (Ktonnes CO2/Year)",size(*0.98)) bar(1,color(khaki)) intensity(50) name(Total,replace) title("A)",position(11)  size(*1.5))

graph bar Rev Burd, over(Country) ytitle("Euros (Thousands)",size(*0.98))  intensity(60) legend(label(1 "Revenue from 179.08 EUR/tonne Carbon Tax") label(2 "Burden from 179.08 EUR/tonne Carbon Tax")  ring(1) position(6)) name(Rev,replace) asyvars bar(1,color(cranberry*0.6)) bar(2,color(edkblue*0.8)) title("D)",position(11)  size(*1.5))

graph combine   Total  EmissionsChange PriceChange Rev,altshrink


gen rev_dif=Rev-Burd

graph bar rev_dif,over(Country)   ytitle("Revenue difference",size(*0.98))  bar(1,color(maroon)) intensity(50) name(pc,replace) title("",position(11) size(*1.5))




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



*****Other Scenarios****** (Carbon cap at 80 and 50 euro carbon tax)
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



*Additional policies*
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


graph bar PriceChangeTax50 ,over(Country)  ytitle("2022 Wholesale Electricity Price Change (EUR/MWh)",size(*1.2)) bar(1, color(green)) intensity(50) name(PriceChange50,replace) title("A)",position(11) size(*1.5))

graph bar EmissionsChangeCarbonCap ,over(Country) ytitle("Output Effect Emission Change (Ktonnes CO2/Year) ",size(*1.2))  bar(1,color(emerald*0.7)) name(EmissionsChangeCC,replace) title("B)		 80 EUR/tonne Carbon Cap",position(11)  size(*1.3))

graph bar EmissionsChangeCarbonTax50 ,over(Country) ytitle("Output Effect Emission Change (Ktonnes CO2/Year) ",size(*1.2))  bar(1,color(emerald*0.7)) name(EmissionsChange50,replace) title("A)   	 50 EUR/tonne Additional Carbon Tax",position(11)  size(*1.3))


graph bar SubCarbonTax50 ,over(Country) ytitle("Substitution Effect Emission Change (Ktonnes CO2/Year) ",size(*1.2))  bar(1,color(maroon*0.7)) name(Sub50,replace) title("C)",position(11)  size(*1.3))

graph bar SubCarbonCap ,over(Country) ytitle("Substitution Effect Emission Change (Ktonnes CO2/Year) ",size(*1.2))  bar(1,color(maroon*0.7)) name(Subcap,replace) title("D)",position(11)  size(*1.3))



**USe these !
graph bar PriceChangeCarbonCap,over(Country) ytitle("2022 Wholesale Electricity Price Change (EUR/MWh) ",size(*1.2)) bar(1, color(green)) intensity(50) name(PriceChangeCC,replace) title("C)",position(11) size(*1.5))

graph bar RevCap totalBurdenCCap, over(Country) ytitle("Euros (Thousands)",size(*1.2))  intensity(60) legend(label(1 "Revenue: Carbon Cap") label(2 "Relief: Carbon Cap")ring(1) position(6)) name(RevCC,replace) asyvars bar(1,color(cranberry*0.6)) bar(2,color(edkblue*0.8)) title("D)",position(11)  size(*1.5))

graph bar total_emissionsCCap ,over(Country) ytitle("Total Emissions Change (Ktonnes CO2/Year)", size(*1.2)) bar(1,color(khaki))  intensity(50) name(TotalCC,replace) title("A)",position(11)  size(*1.5))

graph bar SubCarbonCap EmissionsChangeCarbonCap ,over(Country) ytitle("Emissions Change (Ktonnes CO2/Year)", size(*1.2)) legend(label(1 "Substitution Effect: Carbon Cap") label(2 "Output Effect: Carbon Cap")ring(1) position(6))   intensity(50) name(SO,replace) title("B)",position(11)  size(*1.5)) asyvars bar(1,color(emerald*0.6)) bar(2,color(maroon*0.8))


graph combine TotalCC SO PriceChangeCC  RevCC  ,altshrink name(CarbonCap,replace) //title("80 EUR/tonne Carbon Cap",size(*1.15)) rows(1)



graph bar Rev50 totalBurdenTax50, over(Country) ytitle("Euros (Thousands)",size(*1.2))  intensity(60) legend(label(1 "Revenue from 50 EUR/tonne Carbon Tax") label(2 "Burden from 50 EUR/tonne Carbon Tax")ring(1) position(6)) name(Rev50,replace) asyvars bar(1,color(cranberry*0.6)) bar(2,color(edkblue*0.8)) title("B)",position(11)  size(*1.5))


cap gen total_emissionsCCap= EmissionsChangeCarbonCap+SubCarbonCap
cap gen total_emissionsTax50=EmissionsChangeCarbonTax50+SubCarbonTax50

cap gen totalBurdenTax50=(avg_load*PriceChangeTax50*1000)/1000
cap gen totalBurdenCCap=(avg_load*PriceChangeCarbonCap*1000)/1000



graph bar total_emissionsTax50 ,over(Country) ytitle("Emissions Change (Ktonnes CO2/Year)", size(*1.2)) bar(1,color(khaki))  intensity(50) name(Total50,replace) title("C)",position(11)  size(*1.5))

//graph bar EmissionsChangeCarbonCap EmissionsChangeCarbonTax50 ,over(Country)  legend( label(1 "180 EUR/MWh Natural Gas Cap") label(2 "Equivalent (12.18 EUR/tonne) Carbon Tax") ring(1) position(6)) ytitle("Output Effect Emission Change (Ktonnes CO2/Year)",size(*0.88))  asyvars bar(2,color(purple)) bar(1,color(emerald)) name(EmissionsChange,replace) title("B)",position(11)  size(*1.5))

//graph bar total_emissionsCCap total_emissionsTax50 ,over(Country) legend( label(1 "80 EUR/tonne Carbon Cap") label(2 "50 EUR/tonne Carbon Tax") ring(1) position(6))  ytitle("Emissions Change (Ktonnes CO2/Year)") asyvars bar(2,color(khaki)) bar(1,color(ebblue)) intensity(50) name(Total,replace) title("D)",position(11)  size(*1.5))

graph combine EmissionsChange50 EmissionsChangeCC Sub50 Subcap , altshrink  name("Effects",replace)
graph export Emissions_effects_SI.jpg, quality(100) replace

**HERE

graph combine PriceChange50 Rev50  Total50,altshrink name(Tax50,replace) title("50 EUR/tonne Additional Carbon Tax",size(*1.15)) rows(1)

graph combine Tax50 CarbonCap, name(Fig4_n,replace) rows(2) altshrink

graph export Fig4_n.jpg, quality(100) replace




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

