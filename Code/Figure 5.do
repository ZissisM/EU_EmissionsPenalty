use main


***Fig 5 / Counterfactuals ****

*gas price if gas cap at 180
**Converted carbon price
gen gas_price_cappedN=price_gas
replace gas_price_cappedN=180 if price_gas>180
replace gas_price_cappedCN=gas_price_cappedN+price_carbon*0.3*0.37
gen rel_gascapN=gas_price_cappedCN/(price_usd_to_eur*price_coal_tonne/8.14+price_carbon*0.3)


**Emissions change based on gas price cap (Subtitution Effect)
drop  diff_2022Percent diff_2022Ch
gen diff_2022Percent=(2.364759-2.247722)*marginal_effectN
replace diff_2022Percent=exp(diff_2022Percent)-1
gen diff_2022Ch=diff_2022Percent*avg_y_coal_lignite 
tabstat diff_2022Ch,by(country)

**Emissions
replace substitution_emissions=(diff_2022Ch*(coal_avg/avg_y_coal_lignite)*830)+(diff_2022Ch*(lignite_avg/avg_y_coal_lignite)*1100)
replace sub_emissions_year=substitution_emissions*24*365/1000000

**relative emissions
gen rel_sub=substitution_emissions/baseline_emissions
tabstat rel_sub change_elecriceCarbonTax_rel change_elecPriceGasCap_rel if sample==1,by(country)


*Electricity Change from Gas Cap (do same with other carbon tax prices, which would have opposite effect (higher price and less electricity demand))

replace change_gaspriceCap=(gas_price_capped-price_gas)
* Need to multiply by emissions factor (like 0.3) to get EUR/MWh
replace change_carbonTax=(carbon_tax*emissions_fac)
*now in EUR/MWh once multiplied by emissions factor 

*avg electricity and load for output effect calculations
egen avg_electricity=mean(electricity_prices) if year==2022,by(country)
egen avg_load=mean(load) if year==2022,by(country)

**change in electricity PRICE 
replace change_gaspriceCap=(gas_price_capped-price_gas) 
replace rel_price_change=change_gaspriceCap
replace change_electricityPriceGasCap=(rel_price_change*passthrough) if year==2022
replace rel_price_change=change_carbonTax
replace change_electricityPriceCarbonTax=(rel_price_change*passthrough)*0.37 if year==2022

tabstat change_electricityPriceGasCap change_electricityPriceCarbonTax if year==2022,by(country)

*relative price change 
replace change_elecPriceGasCap_rel= change_electricityPriceGasCap/avg_electricity 
replace change_elecriceCarbonTax_rel= change_electricityPriceCarbonTax/avg_electricity 


*Change electricity generation from price change (output effect)
replace change_electricityGenGasCap=change_electricityPriceGasCap/avg_electricity*elasticity*avg_load*1000 if year==2022
replace change_electricityGenCarbonTax=change_electricityPriceCarbonTax/avg_electricity*elasticity*avg_load*1000 if year==2022

*Emissions change from output effect, per year in correct units
replace change_emissionsGasCap=change_electricityGenGasCap*emissions_fac*24*365/1000
replace change_emissionsCarbonTax=change_electricityGenCarbonTax*emissions_fac*24*365/1000

*KILOTONNES/YEAR
tabstat change_emissionsGasCap change_emissionsCarbonTax sub_emissions_year if year==2022,by(country)

*Save to excel
putexcel set Fig4_new2, replace

putexcel A1 = "Country"
putexcel B1= "Price Change Gas Cap" 
putexcel C1= "Price Change Carbon Tax" 
putexcel D1="Average emissions factor"
putexcel E1="Emissions Change Gas Cap" //Output (gas cap)
putexcel F1="Emissions Change Carbon Tax" //Output (carbon levy)
putexcel G1="Emissions Change 2022" //Substitution

*no IE as mentioned because no price data 
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


//import excel "/Users/ZMarmarelis/Downloads/Fig5_new.xlsx", sheet("Sheet1") firstrow clear

**Dataset with updated values for countries
use Fig5_new,clear 

*Total Emissions adding substitution and output effect
replace total_emissionsCap=-EmissionsChange2022+EmissionsChangeGasCap
replace total_emissionsTax=EmissionsChangeCarbonTax-EmissionsChange2022 

*Carbon revenue calcuation from carbon equivalent price (12.18 EUR/tonne)
*divide by 1000 to be in thousands euros
replace Carbon_Revenue=12.18*avg_load*1000/Averageemissionsfactor/1000


*divide by 1000 to be in thousands euros
replace totalBurdenTax=(avg_load*PriceChangeCarbonTax*1000)/1000
replace totalBurdenCap=(avg_load*PriceChangeGasCap*1000)/1000

replace relief=-totalBurdenCap
replace rev_dif=Carbon_Revenue-totalBurdenTax

//cap gen exclude=0
//replace exclude=1 if Country=="DE"
//replace exclude=1 if Country=="PL"


*relative sub graph 
*Supp. Fig. XX
graph bar rel_sub,over(Country)  ytitle("Relative Substitution Emissions Change") intensity(50) name(Total,replace) title("",position(11)  size(*1.5))

*relative output effect 
* Supp. Fig. XX
graph bar  change_elecPriceGasCap_rel change_elecriceCarbonTax_rel   ,over(Country)  legend( label(1 "180 EUR/MWh Natural Gas Cap") label(2 "Equivalent (12.18 EUR/tonne) Carbon Tax") ring(1) position(6)) ytitle("Relative 2022 Wholesale Electricity Price Change",size(*0.88)) asyvars bar(2,color(maroon)) bar(1,color(green)) intensity(50) name(PriceChange,replace) title("C)",position(11) size(*1.5))

*Substitution effect (ktonnes/year)
*Supp. Fig. XX
graph bar  subYN   ,over(Country) ytitle("Substitution (Ktonnes CO2/year)",size(*0.88))  intensity(50) name(PriceChange,replace) title("",position(11) size(*1.5))

*Changed this to have subYN (new subyear from above)
replace total_emissionsCap=-subYN+EmissionsChangeGasCap
replace total_emissionsTax=EmissionsChangeCarbonTax-subYN 



*Panel C
graph bar PriceChangeGasCap PriceChangeCarbonTax  ,over(Country)  legend( label(1 "180 EUR/MWh Natural Gas Cap") label(2 "Equivalent (12.18 EUR/tonne) Carbon Tax") ring(1) position(6)) ytitle("2022 Wholesale Electricity Price Change (EUR/MWh)",size(*0.88)) asyvars bar(2,color(maroon)) bar(1,color(green)) intensity(50) name(PriceChange,replace) title("C)",position(11) size(*1.5))
graph export "fig5c.svg", as(svg) width(2500) replace

**Unused 
//tw bar EmissionsChangeGasCap EmissionsChangeCarbonTax sub, over(country_id) barw(0.4) barw(0.2) legend( label(1 "Output Effect: 180 EUR/MWh Natural Gas Cap ") label(2 "Output Effect: Equivalent (12.18 EUR/tonne) Carbon Tax") label(3 "Substitution Effect") ring(1) position(6)) ytitle("Emission Change (Ktonnes CO2/Year)",size(*0.88))  name(EmissionsChange,replace) title("B)",position(11)  size(*1.5)) || rcap EmissiosnChangeGasCapLow EmissiosnChangeGasCapHigh country_id || rcap  EmissiosnChangeCarbonTaxLow EmissiosnChangeCarbonTaxHigh country_id

**Unused
//graph bar EmissionsChangeGasCap EmissionsChangeCarbonTax sub EmissiosnChangeGasCapHigh EmissiosnChangeCarbonTaxHigh  ,over(Country)  legend( label(1 "Output Effect: 180 EUR/MWh Natural Gas Cap ") label(2 "Output Effect: Equivalent (12.18 EUR/tonne) Carbon Tax") label(3 "Substitution Effect") label(4 "") label(5 "") ring(1) position(6)) ytitle("Emission Change (Ktonnes CO2/Year)",size(*0.88))  asyvars bar(2,color(purple)) bar(1,color(emerald)) bar(4,color(white))  bar(5,color(white)) intensity(50) name(EmissionsChange,replace) title("B)",position(11)  size(*1.5))

**Panel B
graph bar EmissionsChangeGasCap EmissionsChangeCarbonTax ,over(Country)  legend( label(1 "Output Effect: 180 EUR/MWh Natural Gas Cap ") label(2 "Output Effect: Equivalent (12.18 EUR/tonne) Carbon Tax") ring(1) position(6)) ytitle("Emission Change (Ktonnes CO2/Year)",size(*0.88))  asyvars bar(2,color(purple)) bar(1,color(emerald)) intensity(50) name(EmissionsChange,replace) title("B)",position(11)  size(*1.5))
graph export "fig5b.svg", as(svg) width(2500) replace

**Panel A
graph bar total_emissionsCap total_emissionsTax ,over(Country) legend( label(1 "180 EUR/MWh Natural Gas Cap") label(2 "Equivalent (12.18 EUR/tonne) Carbon Tax") ring(1) position(6))  ytitle("Total Emissions Change (Ktonnes CO2/Year)") asyvars bar(2,color(khaki)) bar(1,color(ebblue)) intensity(50) name(Total,replace) title("A)",position(11)  size(*1.5))
graph export "fig5a.svg", as(svg) width(2500) replace

**Panel D
graph bar Carbon_Revenue totalBurdenTax relief, over(Country) ytitle("Euros (Thousands)")  intensity(60) legend(label(1 "Revenue from 12.18 EUR/tonne Carbon Tax") label(2 "Burden from 12.18 EUR/tonne Carbon Tax") label(3 "Relief from 180 EUR/MWh Gas Cap") ring(1) position(6)) name(Rev,replace) asyvars bar(1,color(cranberry*0.6)) bar(2,color(edkblue*0.8)) bar(2,color(emerald*0.7)) title("D)",position(11)  size(*1.5))
graph export "fig5d.svg", as(svg) width(2500) replace


graph combine Total  EmissionsChange PriceChange Rev  ,altshrink  
graph export Fig5.svg, as(svg) width(3000) replace



**Relative

graph bar  change_elecPriceGasCap_rel change_elecriceCarbonTax_rel  ,over(Country)   legend( label(1 "180 EUR/MWh Natural Gas Cap") label(2 "Equivalent (12.18 EUR/tonne) Carbon Tax") ring(1) position(6)) ytitle("2022 Relative Wholesale Electricity Price Change (EUR/MWh)",size(*0.88)) asyvars bar(2,color(maroon)) bar(1,color(green)) intensity(50) name(rPriceChange,replace) title("",position(11) size(*1.5))

graph bar change_elecPriceGasCap_rel change_elecriceCarbonTax_rel  ,over(Country)  legend( label(1 "180 EUR/MWh Natural Gas Cap") label(2 "Equivalent (12.18 EUR/tonne) Carbon Tax") ring(1) position(6)) ytitle("2022 Relative Wholesale Electricity Price Change (EUR/MWh)",size(*0.88)) asyvars bar(2,color(maroon)) bar(1,color(green)) intensity(50) name(PriceChange,replace) title("",position(11) size(*1.5))
