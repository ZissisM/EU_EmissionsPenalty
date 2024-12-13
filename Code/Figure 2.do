

*imported dataset has generations, electricity prices, gas prices and coal prices
import delimited "/Users/ZMarmarelis/Desktop/Taraq_transfer/EU_workspace/data/ukraine/_17_3b_regression_cleanV3.csv", clear 


use ukraine_17b

gen double t=clock(t,"YMDhms")
format t %tc



gen rel_testN= (price_gas+price_carbon*0.37*0.3)/(price_usd_to_eur*price_coal_tonne/8.14+price_carbon*0.3)
gen gas_p_c=price_gas+price_carbon*0.37
gen sample=1 if dt>22370 & dt<22797 
replace sample=0 if missing(sample)


// 	1.252849 // Jan-March 2021
// 	1.878083 //Sample
// 	2.364759  // 2022
// 	1.805 // Low Price
// 	2.7 //Avg price
// 	3.63  //High price


egen max_coal=max(y_coal_lignite) if sample==1,by(country)
*capacity factor
gen cf_coal=(total_coal/max_coal)
egen avg_y_coal_lignite = mean(y_coal_lignite) if sample == 1, by(country)

egen avg_electricity=mean(electricity_prices) if year==2022,by(country)
egen avg_load=mean(load) if year==2022,by(country)


cap drop marginal_effect1 se_marginal_effect1 marginal_effect2 se_marginal_effect2 marginal_effect3
cap gen marginal_effect1 = .
cap gen se_marginal_effect1 = .
cap gen marginal_effect2 = .
cap gen se_marginal_effect2 = .
cap gen marginal_effect3 = .
gen marginal_effectN=.



***Calculate marginal effect**
//foreach y in  "GR"  {
foreach y in "BG" "CZ" "DE" "DK" "ES" "FI"  "HR" "HU" "IT" "IE" "NL" "PL" "RO" {

	reg  lncoalgen c.rel_testN##c.rel_testN##c.rel_testN##i.hour ire load load_sq i.dow i.month if sample == 1 & country == "`y'", cl(dt)
	//GR has different time FE because of how their gas market works (GR later)
	//reg  lncoalgen c.rel_testN##c.rel_testN##c.rel_testN##i.hour ire load load_sq i.dow c.dt if sample == 1 & country == "`y'", cl(dt)
	margins, dydx(rel_testN) post
	matrix M = r(b)
    scalar effect_rel_testN = M[1,1]
	replace marginal_effectN = effect_rel_testN if country == "`y'"
}



gen counter_check=.
gen excess_check=.
label var counter_check "Different baseline reference"
label var excess_check "With different baseline reference"
//rel_testN=1.1


gen counter_check2=.
gen excess_check2=.
label var counter_check2 "Different baseline reference"
label var excess_check2 "With different baseline reference"
/// rel_testN=1.4


***Calculate Excess Coal 
//foreach y in "BG" "CZ" "DE" "DK" "ES" "FI"  "HR" "HU" "IT" "IE" "NL" "PL" "RO" {
foreach y in "GR"{
	
	reg  lncoalgen c.rel_testN##c.rel_testN##c.rel_testN i.hour ire load load_sq i.dow i.month if sample == 1 & country == "`y'", cl(dt)
	//GR has different time FE because of how their gas market works (GR later)
	//reg  lncoalgen c.rel_testN##c.rel_testN##c.rel_testN i.hour ire load load_sq i.dow c.dt if sample == 1 & country == "`y'", cl(dt)
	*This is the right comparison-- 2021 January-March (inclusive) mean rel_testN
	////actual sample price is  1.878083 rel_testN
	margins, at(rel_testN=1.252849) post
	*This is a different comparison baseline check (Supp. Fig. XX)
	//margins, at(rel_testN=1.1) post

	//margins, coeflegend
	//replace counter = exp(_b[_cons]) if country == "`y'"
	matrix M = r(b)
    scalar predicted_lncoalgen = M[1,1]  // This gets the log coal generation
    scalar predi = exp(predicted_lncoalgen)  // Convert log scale to original scale 
	//replace counter_check = predi if country == "`y'"
	//replace excess_check = avg_y_coal_lignite/1000 - counter_check if country == "`y'"
	replace counter = predi if country == "`y'"
	replace excess = avg_y_coal_lignite/1000 - counter if country == "`y'"

}
//replace excess_check2= excess_check2*1000
//replace excess_check= excess_check*1000
**Different robustness checks under different price ratio comparison (Supp. Fig. XX-XX)
tabstat excess excess_check2 excess_check,by(country)
//replace excess=excess*1000
tabstat excess,by(country)
tabstat baseline_gen,by(country)
cap replace relative_gen=excess/baseline_gen
tabstat relative_gen,by(country)
tabstat avg_y_coal_lignite,by(country)

*excess EMISSIONS
egen coal_avg=mean(y_coal) if sample==1,by(country)
egen lignite_avg=mean(y_lignite) if sample==1,by(country)
replace coal_emissions=(coal_avg/avg_y_coal_lignite)*excess*830
replace lignite_emissions=(lignite_avg/avg_y_coal_lignite)*excess*1100

replace emissions=(coal_emissions+lignite_emissions)*24*365/1000000

replace baseline_emissions2=(coal_avg*830+lignite_avg*1100)*24*365/1000000
replace relative_emissions2=(coal_emissions+lignite_emissions)/baseline_emissions2
tabstat relative_emissions2,by(country)
tabstat baseline_emissions2,by(country)
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



***Excess Wholesale Price***
**What is excess wholesale price? The observed price - predicted the price under lower ratio (1.252849)

drop wholesale_exc
gen wholesale_exc=.
eststo clear 
foreach y in "BG" "CZ" "DE" "DK" "ES" "FI"  "HR" "HU" "IT" "NL" "PL" "RO" {
//foreach y in "GR" {
	reg electricity_prices price_gas i.month i.hour i.dow ire c.load##c.load if country=="`y'" & sample==1,cl(dt)
	//GR is different again (no month FE)
	//reg electricity_prices price_gas c.dt i.hour i.dow ire c.load##c.load if country=="`y'" & sample==1,cl(dt)
	replace passthrough=_b[price_gas] if country=="`y'"
	}
 }
 replace wholesale_counter=passthrough*32.29858 if sample==1
replace wholesale_excess=electricity_prices-wholesale_counter if sample==1
tabstat wholesale_excess, by (country)
tabstat wholesale_exessc,by(country)



**Panel G
graph box electricity_prices if sample==1 & !missing(electricity_prices),over(country,sort(1)) title("Electricity Price Distribution April 2021-June 2022") intensity(55)  ylabel(,labsize(*1.3)) ytitle("EUR/MWh",size(*1.3)) asyvars nooutsides showyvars legend(off)
graph export "fig2g.svg", as(svg) width(2300) replace



**Panel D
graph box y_coal_lignite if sample==1,over(country,sort(1)) title("Coal Generation April 2021-June 2022") intensity(65) ylabel(,labsize(*1.3)) ytitle("MWh",size(*1.3)) asyvars nooutsides showyvars legend(off)
graph export "fig2d.svg", as(svg) width(2300) replace


**Panel C
use excess_scat
graph hbar coalM if !missing(correl),over(labels,sort(1) descending) ytitle("Average Coal Respsonsiveness") bar(1, color(emerald%85)) ylabel(,labsize(*1.4)) name(coalR,replace) title("",size(*1.3) pos(11))
graph export "fig2c.svg", as(svg) width(2300) replace

**Panel F
graph hbar passthrough if !missing(correl),over(labels,sort(1) descending) ytitle("Average Pass-through Coefficient") bar(1, color(sand%85)) ylabel(,labsize(*1.4)) name(pass,replace) title("",size(*1.3) pos(11))
graph export "fig2f.svg", as(svg) width(2300) replace




