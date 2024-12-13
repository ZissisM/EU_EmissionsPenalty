**Carbon Cap 
*****Other Scenarios****** REDO!!!! Coming out wrong !!!! For Fig 5_ukraine to plot 
*Carbon price if it is capped at 80 (Cheaper coal so higher relative price so more coal CF/emissions)


gen carbon_capped=price_carbon 
replace carbon_capped=80 if price_carbon>80
replace gas_carbon_capped=price_gas+carbon_capped*0.37*0.3
replace coal_carboncapped=price_usd_to_eur*price_coal_tonne/8.14+carbon_capped*0.3
replace rel_carboncapped=gas_carbon_capped/coal_carboncapped
replace rel_carboncapped2=rel_carboncapped^2
*Under frozen carbon price in 2022
replace excess_carboncap=exp(marginal_effectN)*(2.399946-2.364759)

tabstat excess_carboncap,by(country)

cap gen gas_p_CC=price_gas+price_carbon*0.37*0.3
replace rel_price_change=gas_carbon_capped-gas_p_CC
replace change_electricityPriceCarbonCap=-(rel_price_change*passthrough)

*multiply this PRICE change by the elasticity estimate, in MWh
replace change_electricityGenCarbonCap=change_electricityPriceCarbonCap/avg_electricity*elasticity*avg_load*1000
//gen change_electricityGenCarbonTax50=change_PriceCarbonTax50/avg_electricity*elasticity*avg_load*1000

tabstat change_electricityGenCarbonCap change_electricityGenCarbonTax50 if year==2022,by(country)

replace change_emissionsCarbonCap=change_electricityGenCarbonCap*emissions_fac*24*365/1000
//gen change_emissionsCarbonTax50=change_electricityGenCarbonTax50*emissions_fac*24*365/1000


*emissions in mega tonne CO2 per year or kilotonnes (multiply by 1000)?? 
gen substitution_emissionsCarbonCap=(excess_carboncap*(coal_avg/avg_y_coal_lignite)*830)+(excess_carboncap*(lignite_avg/avg_y_coal_lignite)*1100)
replace sub_emissions_yearCarbonCap=substitution_emissionsCarbonCap*24*365/1000000
//tabstat sub_emissions_yearCarbonCap,by(country)


//gen Carbon_Revenue50=50*avg_load*1000/emissions_fac/1000
replace Carbon_RevenueCarbonCap=(carbon_capped-price_carbon)*avg_load*1000/emissions_fac/1000


replace total_emissionsCCap= EmissionsChangeCarbonCap+SubCarbonCap
replace totalBurdenCCap=-(avg_load*PriceChangeCarbonCap*1000)/1000


**USe these !
graph bar PriceChangeCarbonCap,over(Country) ytitle("2022 Wholesale Electricity Price Change (EUR/MWh) ",size(*1.2)) bar(1, color(green)) intensity(50) name(PriceChangeCC,replace) title("C)",position(11) size(*1.5))

graph bar RevCap totalBurdenCCap, over(Country) ytitle("Euros (Thousands)",size(*1.2))  intensity(60) legend(label(1 "Revenue: Carbon Cap") label(2 "Relief: Carbon Cap")ring(1) position(6)) name(RevCC,replace) asyvars bar(1,color(cranberry*0.6)) bar(2,color(edkblue*0.8)) title("D)",position(11)  size(*1.5))

graph bar total_emissionsCCap ,over(Country) ytitle("Total Emissions Change (Ktonnes CO2/Year)", size(*1.2)) bar(1,color(khaki))  intensity(50) name(TotalCC,replace) title("A)",position(11)  size(*1.5))

graph bar SubCarbonCap EmissionsChangeCarbonCap ,over(Country) ytitle("Emissions Change (Ktonnes CO2/Year)", size(*1.2)) legend(label(1 "Substitution Effect: Carbon Cap") label(2 "Output Effect: Carbon Cap")ring(1) position(6))   intensity(50) name(SO,replace) title("B)",position(11)  size(*1.5)) asyvars bar(1,color(emerald*0.6)) bar(2,color(maroon*0.8))


graph combine TotalCC SO PriceChangeCC  RevCC  ,altshrink name(CarbonCap,replace) //title("80 EUR/tonne Carbon Cap",size(*1.15)) rows(1)
