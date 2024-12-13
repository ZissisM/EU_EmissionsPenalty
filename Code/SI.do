use ukraine_17b

**SI figures and tables and calculations


**Timeseries of gas, carbon price, relative price 
**Supp. Fig. XX-XX
tw line price_gas t if sample==1 | year==2022, yline(180) sort xlabel(, format(%tCMon-CCYY)) xtitle("") ytitle("Natural Gas Price (EUR/MWh)") lwidth(*1.4) lcolor(maroon*0.8) name(g,replace)
tw line price_carbon t if sample==1 | year==2022, yline(80) sort xlabel(, format(%tCMon-CCYY)) xtitle("") ytitle("Carbon price (EUR/ton CO2)") lwidth(*1.4) lcolor(dkorange*0.8) name(c,replace)
tw line rel_testN t if sample==1 | year==2022,sort xlabel(, format(%tCMon-CCYY)) xtitle("") lwidth(*1.4) lcolor(emerald*0.8) name(r,replace)
graph combine g c r, rows(3) width(1500) altshrink

**Excess Scatter Plots
**Supp. Fig. XX

robreg mm excess_price gas_share if exclude==0
matrix b=e(b)
cap gen z7=1 
replace z7= 11 if Country=="CZ"
replace z7= 3 if Country=="LT"
replace z7= 1 if Country=="DE"
replace z7= 9 if Country=="NO"
replace z7= 10 if Country=="CH"
replace z7= 3 if Country=="RO"
replace z7= 12 if Country=="HU"
replace z7= 1 if Country=="FI"
replace z7= 3 if Country=="EE"
replace z7= 5 if Country=="PL"
replace z7= 3 if Country=="PT"
replace z7= 12 if Country=="HR"
replace z7= 8 if Country=="AT"
replace z7= 3 if Country=="BG"
replace z7= 2 if Country=="DK"


twoway scatter excess_price gas_share if exclude==0, mlabel(labels) mlabvposition(z7) mlabsize(*1.3) msymbol(d) mcolor(maroon%75) msize(*1.5) color(navy) graphregion(lstyle(none)) title("C)",position(11) size(*1.4)) xtitle("Gas share",size(*1.47)) ylabel(,labsize(*1.6) grid gmax gmin glwidth(0.5)) legend(off) xlabel(,labsize(*1.5)) ytitle(Excess Electricity Price (EUR/MWh),size(*1.47)) name(gasP,replace) || function y=_b[gas_share]*x+_b[_cons],range(gas_share) || lfit excess_price gas_share if exclude==0, lcolor(ebblue*0.5) 



robreg mm excess_price decarb_share if exclude==0
matrix b=e(b)
cap gen z7=1 
replace z7= 3 if Country=="CZ"
replace z7= 3 if Country=="LT"
replace z7= 1 if Country=="DE"
replace z7= 9 if Country=="NO"
replace z7= 10 if Country=="CH"
replace z7= 3 if Country=="RO"
replace z7= 12 if Country=="HU"
replace z7= 6 if Country=="SI"
replace z7= 3 if Country=="FI"
replace z7= 3 if Country=="EE"
replace z7= 5 if Country=="PL"
replace z7= 3 if Country=="PT"
replace z7= 3 if Country=="HR"
replace z7= 8 if Country=="AT"
replace z7= 12 if Country=="BG"
replace z7= 2 if Country=="DK"
replace z7= 4 if Country=="GR"



twoway scatter excess_price decarb_share if exclude==0, mlabel(labels) mlabvposition(z7) mlabsize(*1.3) msymbol(d) mcolor(maroon%75) msize(*1.5) color(navy) graphregion(lstyle(none)) title("A)",position(11) size(*1.4)) xtitle("Decarbonized share",size(*1.47)) ylabel(,labsize(*1.6) grid gmax gmin glwidth(0.5)) legend(off) xlabel(,labsize(*1.5)) ytitle(Excess Electricity Price (EUR/MWh),size(*1.47)) name(decarbP,replace) || function y=_b[decarb_share]*x+_b[_cons],range(decarb_share) || lfit excess_price decarb_share if exclude==0, lcolor(ebblue*0.5) 




**Relative Index Scatter Plots

robreg mm correl gas_share if exclude==0
matrix b=e(b)
cap gen z7=1 
replace z7= 2 if Country=="BG"
replace z7= 10 if Country=="GR"




twoway scatter correl gas_share if exclude==0, mlabel(labels) mlabvposition(z7) mlabsize(*1.5) msymbol(d) mcolor(maroon%75) msize(*1.5) color(navy) graphregion(lstyle(none)) title("A)",position(11) size(*1.4)) xtitle("Gas share",size(*1.47)) ylabel(,labsize(*1.6) grid gmax gmin glwidth(0.5)) legend(off) xlabel(,labsize(*1.5)) ytitle("Relative Responsiveness",size(*1.4)) name(gasscorr,replace) || function y=_b[gas_share]*x+_b[_cons],range(gas_share) || lfit correl gas_share if exclude==0, lcolor(ebblue*0.5) 


robreg mm correl ire_share if exclude==0
matrix b=e(b)
cap gen z7=1 
replace z7= 9 if Country=="DK"
replace z7= 1 if Country=="IT"



twoway scatter correl ire_share if exclude==0, mlabel(labels) mlabvposition(z7) mlabsize(*1.5) msymbol(d) mcolor(maroon%75) msize(*1.5) color(navy) graphregion(lstyle(none)) title("B)",position(11) size(*1.4)) xtitle("IRE share",size(*1.47)) ylabel(,labsize(*1.6) grid gmax gmin glwidth(0.5)) legend(off) xlabel(,labsize(*1.5)) ytitle("Relative Responsiveness",size(*1.4)) name(irecorr,replace) || function y=_b[ire_share]*x+_b[_cons],range(ire_share) || lfit correl ire_share if exclude==0, lcolor(ebblue*0.5) 




robreg mm correl nuc_share if exclude==0
matrix b=e(b)
cap gen z7=1 
replace z7= 3 if Country=="FI"
replace z7= 1 if Country=="ES"
replace z7= 9 if Country=="IT"
replace z7= 9 if Country=="HU"
replace z7= 12 if Country=="PL"
replace z7= 5 if Country=="IT"
replace z7= 3 if Country=="GR"
replace z7= 3 if Country=="NL"
replace z7= 3 if Country=="HR"





twoway scatter correl nuc_share if exclude==0, mlabel(labels)  mlabvposition(z7) mlabsize(*1.5) msymbol(d) mcolor(maroon%75) msize(*1.5) color(navy) graphregion(lstyle(none)) title("A)",position(11) size(*1.4)) xtitle("Nuclear share",size(*1.47)) ylabel(,labsize(*1.6) grid gmax gmin glwidth(0.5)) legend(off) xlabel(,labsize(*1.5)) ytitle("Relative Responsiveness",size(*1.4)) name(coalcorr,replace) || function y=_b[nuc_share]*x+_b[_cons],range(nuc_share) || lfit correl nuc_share if exclude==0, lcolor(ebblue*0.5) 


robreg mm correl hydro_share if exclude==0
matrix b=e(b)
cap gen z7=1 
replace z7= 2 if Country=="BG"
replace z7= 10 if Country=="GR"
replace z7= 3 if Country=="NL"
replace z7= 11 if Country=="IT"
replace z7= 9 if Country=="HR"
replace z7= 4 if Country=="PL"




twoway scatter correl hydro_share if exclude==0, mlabel(labels) mlabvposition(z7) mlabsize(*1.5) msymbol(d) mcolor(maroon%75) msize(*1.5) color(navy) graphregion(lstyle(none)) title("B)",position(11) size(*1.4)) xtitle("Hydro share",size(*1.47)) ylabel(,labsize(*1.6) grid gmax gmin glwidth(0.5)) legend(off) xlabel(,labsize(*1.5)) ytitle("Relative Responsiveness",size(*1.4)) name(gasscorr,replace) || function y=_b[hydro_share]*x+_b[_cons],range(hydro_share) || lfit correl hydro_share if exclude==0, lcolor(ebblue*0.5) 


robreg mm correl solar_share if exclude==0
matrix b=e(b)
cap gen z7=1 
replace z7= 9 if Country=="DK"
replace z7= 1 if Country=="IT"
replace z7= 3 if Country=="NL"
replace z7= 9 if Country=="ES"
replace z7= 9 if Country=="HR"





twoway scatter correl solar_share if exclude==0, mlabel(labels) mlabvposition(z7) mlabsize(*1.5) msymbol(d) mcolor(maroon%75) msize(*1.5) color(navy) graphregion(lstyle(none)) title("C)",position(11) size(*1.4)) xtitle("Solar share",size(*1.47)) ylabel(,labsize(*1.6) grid gmax gmin glwidth(0.5)) legend(off) xlabel(,labsize(*1.5)) ytitle("Relative Responsiveness",size(*1.4)) name(irecorr,replace) || function y=_b[solar_share]*x+_b[_cons],range(solar_share) || lfit correl solar_share if exclude==0, lcolor(ebblue*0.5) 


robreg mm correl wind_share if exclude==0
matrix b=e(b)
cap gen z7=1 
replace z7= 1 if Country=="DK"
replace z7= 9 if Country=="HR"
replace z7= 4 if Country=="ES"
replace z7= 4 if Country=="RO"
replace z7= 9 if Country=="IT"
replace z7= 1 if Country=="HU"




twoway scatter correl wind_share if exclude==0, mlabel(labels) mlabvposition(z7) mlabsize(*1.5) msymbol(d) mcolor(maroon%75) msize(*1.5) color(navy) graphregion(lstyle(none)) title("D)",position(11) size(*1.4)) xtitle("Wind share",size(*1.47)) ylabel(,labsize(*1.6) grid gmax gmin glwidth(0.5)) legend(off) xlabel(,labsize(*1.5)) ytitle("Relative Responsiveness",size(*1.4)) name(decorr,replace) || function y=_b[wind_share]*x+_b[_cons],range(wind_share) || lfit correl wind_share if exclude==0, lcolor(ebblue*0.5) 


graph combine coalcorr gasscorr irecorr decorr , rows(2) altshrink  name(correlations,replace)




**Supp. Tab. XX-XX
**Robustness is passthrough of carbon price to electricity price is 0.2 of the passthrough of NG to electricity, or if it is 0.5
gen change_electricityPriceCarbonTa2=(rel_price_change*passthrough)*0.2
gen change_electricityPriceCarbonTa3=(rel_price_change*passthrough)*0.5
gen change_electricityGenCarbonTx2=change_electricityPriceCarbonTa2/avg_electricity*elasticity*avg_load*1000
gen change_electricityGenCarbonTa3=change_electricityPriceCarbonTa3/avg_electricity*elasticity*avg_load*1000
gen change_emissionsCarbonTa2=change_electricityGenCarbonTx2*emissions_fac*24*365/1000
gen change_emissionsCarbonTa3=change_electricityGenCarbonTa3*emissions_fac*24*365/1000

gen total_emissionsTax2=change_emissionscarbonta2-subYN 
gen total_emissionsTax3=change_emissionscarbonta3-subYN 

gen totalBurdenTax2=(avg_load*change_electricitypricecarbonta2*1000)/1000
gen totalBurdenTax3=(avg_load*change_electricitypricecarbonta3*1000)/1000



graph bar change_electricitypricecarbonta2 change_electricitypricecarbonta3  ,over(Country)  legend( label(1 "Carbon Tax with lower pass-through assumption") label(2 "Carbon Tax with higher pass-through assumption") ring(1) position(6)) ytitle("2022 Wholesale Electricity Price Change (EUR/MWh)",size(*0.88)) asyvars bar(2,color(maroon)) bar(1,color(green)) intensity(50) name(PriceChange,replace) title("C)",position(11) size(*1.5))

graph bar change_emissionscarbonta2 change_emissionscarbonta3 ,over(Country) legend( label(1 "Carbon Tax with lower pass-through assumption") label(2 "Carbon Tax with higher pass-through assumption") ring(1) position(6)) ytitle("Emission Change (Ktonnes CO2/Year)",size(*0.88))  asyvars bar(2,color(purple)) bar(1,color(emerald)) intensity(50) name(EmissionsChange,replace) title("B)",position(11)  size(*1.5))

graph bar total_emissionsTax2 total_emissionsTax3 ,over(Country) legend( label(1 "Carbon Tax with lower pass-through assumption") label(2 "Carbon Tax with higher pass-through assumption") ring(1) position(6))  ytitle("Total Emissions Change (Ktonnes CO2/Year)") asyvars bar(2,color(khaki)) bar(1,color(ebblue)) intensity(50) name(Total,replace) title("A)",position(11)  size(*1.5))

graph bar Carbon_Revenue totalBurdenTax2 totalBurdenTax3, over(Country) ytitle("Euros (Thousands)")  intensity(60) legend(label(1 "Revenue from 12.18 EUR/tonne Carbon Tax") label(2 "Burden from carbon tax with lower pass-through assumption") label(3 "Burden from carbon tax with higher pass-through assumption") ring(1) position(6)) name(Rev,replace) asyvars bar(1,color(cranberry*0.6)) bar(2,color(edkblue*0.8)) bar(2,color(emerald*0.7)) title("D)",position(11)  size(*1.5))

graph combine  Total  EmissionsChange PriceChange Rev  ,altshrink




***EDF 1

robreg mm correl change_elecPriceGasCap_rel if exclude==0
matrix b=e(b)
replace z7=3 if Country=="RO"
replace z7=1 if Country=="ES"
replace z7=9 if Country=="CZ"
replace z7=4 if Country=="NL"
replace z7=9 if Country=="GR"
replace z7=4 if Country=="HR"


twoway scatter correl change_elecPriceGasCap_rel if exclude==0, mlabel(labels)  mlabvposition(z7) mlabsize(*1.5) msymbol(d) mcolor(maroon%75) msize(*1.5) color(navy) graphregion(lstyle(none)) title("B)",position(11) size(*1.4)) xtitle("Relative Wholesale Electricity Price Decrease: Gas Cap",size(*1.47)) ylabel(,labsize(*1.6) grid gmax gmin glwidth(0.5)) legend(off) xlabel(,labsize(*1.5)) ytitle("Relative Responsiveness Index",size(*1.4)) name(PriceCorr_gas,replace) || function y=_b[change_elecPriceGasCap_rel]*x+_b[_cons],range(change_elecPriceGasCap_rel) || lfit correl change_elecPriceGasCap_rel if exclude==0, lcolor(ebblue*0.5) 



robreg mm correl change_elecriceCarbonTax_rel if exclude==0
matrix b=e(b)
replace z7=3 if Country=="RO"
replace z7=6 if Country=="ES"
replace z7=9 if Country=="CZ"
replace z7=9 if Country=="NL"
replace z7=9 if Country=="GR"
replace z7=9 if Country=="HR"


twoway scatter correl change_elecriceCarbonTax_rel if exclude==0, mlabel(labels)  mlabvposition(z7) mlabsize(*1.5) msymbol(d) mcolor(maroon%75) msize(*1.5) color(navy) graphregion(lstyle(none)) title("A)",position(11) size(*1.4)) xtitle("Relative Wholesale Electricity Price Increase: Additional Carbon Tax",size(*1.47)) ylabel(,labsize(*1.6) grid gmax gmin glwidth(0.5)) legend(off) xlabel(,labsize(*1.5)) ytitle("Relative Responsiveness Index",size(*1.4)) name(PriceCorr_carb,replace) || function y=_b[change_elecriceCarbonTax_rel]*x+_b[_cons],range(change_elecriceCarbonTax_rel) || lfit correl change_elecriceCarbonTax_rel if exclude==0, lcolor(ebblue*0.5) 

graph combine PriceCorr_carb PriceCorr_gas,altshrink row(1)



robreg mm correl PriceChangeGasCap if exclude==0
matrix b=e(b)
replace z7=9 if Country=="RO"
replace z7=1 if Country=="ES"
replace z7=9 if Country=="CZ"
replace z7=3 if Country=="NL"
replace z7=9 if Country=="GR"


twoway scatter correl PriceChangeGasCap if exclude==0, mlabel(labels)  mlabvposition(z7) mlabsize(*1.5) msymbol(d) mcolor(maroon%75) msize(*1.5) color(navy) graphregion(lstyle(none)) title("D)",position(11) size(*1.4)) xtitle("Wholesale Electricity Price (EUR/MWh) Decrease: Gas Cap",size(*1.47)) ylabel(,labsize(*1.6) grid gmax gmin glwidth(0.5)) legend(off) xlabel(,labsize(*1.5)) ytitle("Relative Responsiveness Index",size(*1.4)) name(PriceCorr_gas2,replace) || function y=_b[PriceChangeGasCap]*x+_b[_cons],range(PriceChangeGasCap) || lfit correl PriceChangeGasCap if exclude==0, lcolor(ebblue*0.5) 



robreg mm correl PriceChangeCarbonTax if exclude==0
matrix b=e(b)
replace z7=3 if Country=="RO"
replace z7=1 if Country=="ES"
replace z7=9 if Country=="CZ"
replace z7=9 if Country=="NL"
replace z7=9 if Country=="GR"


twoway scatter correl PriceChangeCarbonTax if exclude==0, mlabel(labels)  mlabvposition(z7) mlabsize(*1.5) msymbol(d) mcolor(maroon%75) msize(*1.5) color(navy) graphregion(lstyle(none)) title("C)",position(11) size(*1.4)) xtitle("Wholesale Electricity Price Increase (EUR/MWh): Additional Carbon Tax",size(*1.47)) ylabel(,labsize(*1.6) grid gmax gmin glwidth(0.5)) legend(off) xlabel(,labsize(*1.5)) ytitle("Relative Responsiveness Index",size(*1.4)) name(PriceCorr_carb2,replace) || function y=_b[PriceChangeCarbonTax]*x+_b[_cons],range(PriceChangeCarbonTax) || lfit correl PriceChangeCarbonTax if exclude==0, lcolor(ebblue*0.5) 

graph combine PriceCorr_carb PriceCorr_gas PriceCorr_carb2 PriceCorr_gas2,altshrink row(2)



***EDF 2 

graph hbar dC dP if !missing(correl),over(labels, sort(1)) ytitle("Average Intensity") bar(1, color(maroon%80)) bar(2, color(emerald%80)) ylabel(,labsize(*1.4)) name(intens,replace) title("",size(*1.3) pos(11)) legend(order(1 "Coal Respsonsiveness" 2 "Price Pass-through"))



***EDF 3

graph hbar solar_share wind_share hydro_share nuc_share gas_share coal_share other_share, stack over(labels, label(labsize(*0.95))) ///
		//relabel(1 " " 2 "Austria" 3 " " 4 "Belgium" 5 "Bulgaria" 6 " " 7 "Croatia" 8 "Czech" 9 "Denmark" 10 "Estonia" 11 "Finland" ///
		//12 "France" 13 "Germany" 14 "Greece" 15 "Hungary" 16 "Italy" 17 "Lithuania" 18 "Netherlands" 19 "Norway" 20 "Poland" 21 "Portugal" 22 "Romania" 23 "Serbia" 24 "Slovakia" 25 "Slovenia" 26 "Spain" 27 "Switzerland" 28 "") ///
		//sort(order))  ysize(6) xsize(8) ///
		ytitle("Share of generation mix (April 2021-June 2022)") graphregion(margin(l+18)) ///
		bar(1, color(orange*0.6)) bar(2, color(midgreen*0.6)) bar(3, color(red*0.6)) ///
		bar(4, color(midblue*0.6)) bar(5, color(sienna*0.5)) bar(6, color(dknavy*0.6)) title("",size(*1.2) position(11)) ylabel(,labsize(*1.1)) legend((1 "Solar") (2 "Wind") (3 "Hydro") (4 "Nuclear") (5 "Natural Gas") (6 "Coal") size(small) position(6) rows(2)) 

		
		
*** Supp. Fig. XX
*Distribution of coal and gas for select countries
foreach y in  "CZ" "DE" "ES" "FI" "GR" "PL" {
graph box coal_share gas_share if sample==1 & country=="`y'", over(hour) title(`y') ytitle("Average Hourly Percent Distribution of Gas and Coal",size(*1.1)) name(`y'box,replace) intensity(55) ylabel(,labsize(*1.3)) legend(size(*1.26) rows(1) pos(6)) box(2, color(midgreen*0.7)) box(1,color(sand*0.9)) marker(2,mcolor(midgreen*0.7)) marker(1,mcolor(sand*0.9))
}
graph combine CZbox DEbox ESbox FIbox GRbox PLbox, altshrink


**Supplementary Tables for every country different specifications
**Supp. Fig XX-XX
**Change specification for Greece to change month fixed efefcts to c.dt linear trend term
foreach y in "CZ" "PL" "GR" "DE" "DK" "FI" "ES" "HU" "NL" "RO" "BG" "HR" "IT" "IE"  {
foreach y in   {


	reg  lncoalgen c.rel_testN##c.rel_testN##c.rel_testN if sample == 1 & country == "`y'", vce(robust)
	margins, dydx(rel_testN)
	local a=r(table)[rownumb(r(table),"b"),1]
	 //reg  cf_coal2 c.rel_testN##c.rel_testN##c.rel_testN if sample==1 & country=="`y'",vce(robust)
	outreg2 using `y'SI_109.doc,replace se label adjr2  bdec(2)  keep(rel_testN c.rel_testN#c.rel_testN c.rel_testN#c.rel_testN#c.rel_testN) addtext(Month FE,NO , Hour FE, NO, Day-of-Week FE, NO, SE, Robust) title(`y') nocons addstat(Marginal Effect, `a') ctitle(" ")
	
	reg  lncoalgen c.rel_testN##c.rel_testN##c.rel_testN ire load load_sq if sample == 1 & country == "`y'",vce(robust)
	margins, dydx(rel_testN)
	local a=r(table)[rownumb(r(table),"b"),1]
	outreg2 using `y'SI_109.doc,append se label adjr2  bdec(2)  keep(rel_testN c.rel_testN#c.rel_testN c.rel_testN#c.rel_testN#c.rel_testN ire load) addtext(Month FE, NO , Hour FE, NO, Day-of-Week FE, NO, SE, Robust) title(`y') nocons  addstat(Marginal Effect, `a') ctitle(" ")
	
	
	reg  lncoalgen c.rel_testN##c.rel_testN##c.rel_testN ire y_nuclear load load_sq if sample == 1 & country == "`y'",vce(robust)
	margins, dydx(rel_testN)
	local a=r(table)[rownumb(r(table),"b"),1]
	outreg2 using `y'SI_109.doc,append se label adjr2  bdec(2)  keep(rel_testN c.rel_testN#c.rel_testN y_nuclear c.rel_testN#c.rel_testN#c.rel_testN ire load load_sq y_nuclear) addtext(Month FE, YES , Hour FE, NO, Day-of-Week FE, NO, SE, Robust) title(`y') nocons  addstat(Marginal Effect, `a') ctitle(" ")
	
	reg  lncoalgen c.rel_testN##c.rel_testN##c.rel_testN ire load load_sq i.month i.hour i.dow if sample == 1 & country == "`y'",vce(robust)
	margins, dydx(rel_testN)
	local a=r(table)[rownumb(r(table),"b"),1]
	outreg2 using `y'SI_109.doc,append se label adjr2  bdec(2)  keep(rel_testN c.rel_testN#c.rel_testN c.rel_testN#c.rel_testN#c.rel_testN ire load load_sq) addtext(Month FE, YES , Hour FE, YES, Day-of-Week FE, YES, SE, Robust) title(`y') nocons  addstat(Marginal Effect, `a') ctitle(" ")
	
	reg  lncoalgen c.rel_testN##c.rel_testN##c.rel_testN ire load load_sq i.month i.hour i.dow if sample==1 & country=="`y'",cl(dt)
	margins, dydx(rel_testN)
	local a=r(table)[rownumb(r(table),"b"),1]
	outreg2 using `y'SI_109.doc,append se label adjr2  bdec(2)  keep(rel_testN c.rel_testN#c.rel_testN c.rel_testN#c.rel_testN#c.rel_testN ire load load_sq) addtext(Month FE, YES , Hour FE, YES, Day-of-Week FE, YES,  SE, Day Clustered) title(`y') nocons  addstat(Marginal Effect, `a') ctitle(" ")
	
	newey  lncoalgen c.rel_testN##c.rel_testN##c.rel_testN i.hour ire load load_sq i.dow i.month if sample == 1 & country == "`y'", lag(2) force 
	margins, dydx(rel_testN)
	local a=r(table)[rownumb(r(table),"b"),1]
	outreg2 using `y'SI_109.doc,append se label  bdec(2)  keep(rel_testN c.rel_testN#c.rel_testN c.rel_testN#c.rel_testN#c.rel_testN ire load load_sq) addtext(Month FE,YES , Hour FE, YES, Day-of-Week FE, YES, SE, Newey) title(`y') nocons addstat(Marginal Effect, `a') ctitle(" ")
}


*Main speicication estimates
**EDF 5
foreach y in "BG" "CZ" "DE" "DK" "ES" "FI" "GR" "HR" "HU" "IT" "IE" "NL" "PL" "RO" {

	if "`y'"=="GR"{
	reg  lncoalgen c.rel_testN##c.rel_testN##c.rel_testN ire load load_sq c.dt i.hour i.dow if sample==1 & country=="`y'",cl(dt)
	margins, dydx(rel_testN)
	local a=r(table)[rownumb(r(table),"b"),1]
		outreg2  using "mainspec_109.doc",  append addtext(Month FE, YES, Hour FE, YES, Day of Week FE, YES) keep(rel_testN rel_testN2 rel_testN3 ire load load_sq) label ctitle(`y') nocons bdec(3) sdec(3) addstat(Marginal Effect, `a')
	}
	else{
		if "`y'"=="BG"{
	reg  lncoalgen c.rel_testN##c.rel_testN##c.rel_testN ire load load_sq i.month i.hour i.dow if sample==1 & country=="`y'",cl(dt)
	margins, dydx(rel_testN)
	local a=r(table)[rownumb(r(table),"b"),1]
			outreg2  using "mainspec_109.doc",  replace addtext(Month FE, YES, Hour FE, YES, Day of Week FE, YES) keep(rel_testN rel_testN2 rel_testN3 ire load load_sq) label ctitle(`y') nocons bdec(3) sdec(3) addstat(Marginal Effect, `a')
		}
		else{
	reg  lncoalgen c.rel_testN##c.rel_testN##c.rel_testN ire load load_sq i.month i.hour i.dow if sample==1 & country=="`y'",cl(dt)
	margins, dydx(rel_testN)
	local a=r(table)[rownumb(r(table),"b"),1]
			outreg2  using "mainspec_109.doc",  append addtext(Month FE, YES, Hour FE, YES, Day of Week FE, YES, SE, Day Clustered) keep(rel_testN rel_testN2 rel_testN3 ire load load_sq) label ctitle(`y') nocons bdec(3) sdec(3) addstat(Marginal Effect, `a')

		}
	}
}


***Functional Form Table 
**Supp. Tab. XX
gen quadratic = .
gen linear = .
gen levels = .
gen loglog = .
gen bic_quad = .
gen bic_lin = .
gen bic_levels = .
gen bic_loglog = .
gen mainsp=.
gen bic_main=.
gen fourth_power=.
gen fifth_power=.
gen bic_fourth=.
gen bic_fifth=.

foreach y in "BG" "CZ" "DE" "DK" "ES" "FI"  "HR" "HU" "IT" "IE" "NL" "PL" "RO" {
	
//foreach y in "GR" {


	reg lncoalgen c.rel_testN##c.rel_testN##c.rel_testN ire load load_sq i.month i.hour i.dow if sample==1 & country=="`y'", cl(dt)
//	reg lncoalgen c.rel_testN##c.rel_testN ire load load_sq c.dt i.hour i.dow if sample==1 & country=="`y'", cl(dt)
    
    // Calculate marginal effects for cubic form
    margins, dydx(rel_testN)
    replace mainsp = r(b)[1,1] if country == "`y'"
	 replace bic_main = -2*e(ll)+e(df_m)*log(e(N)) if country == "`y'"
    
    // First regression with cubic term
    reg lncoalgen c.rel_testN##c.rel_testN ire load load_sq i.month i.hour i.dow if sample==1 & country=="`y'", cl(dt)
	//reg lncoalgen c.rel_testN##c.rel_testN ire load load_sq c.dt i.hour i.dow if sample==1 & country=="`y'", cl(dt)
    
    // Calculate marginal effects for cubic form
    margins, dydx(rel_testN)
    replace quadratic = r(b)[1,1] if country == "`y'"
	 replace bic_quad = -2*e(ll)+e(df_m)*log(e(N)) if country == "`y'"
	       

    // Second regression without cubic term
    reg lncoalgen c.rel_testN ire load load_sq i.month i.hour i.dow if sample==1 & country=="`y'", cl(dt)
   // reg lncoalgen c.rel_testN ire load load_sq c.dt i.hour i.dow if sample==1 & country=="`y'", cl(dt)

    // Calculate marginal effects for linear form
    margins, dydx(rel_testN)
    replace linear = r(b)[1,1] if country == "`y'"
	 replace bic_lin =  -2*e(ll)+e(df_m)*log(e(N)) if country == "`y'"

	
   reg coalgen c.rel_testN##c.rel_testN##c.rel_testN ire load load_sq i.month i.hour i.dow if sample==1 & country=="`y'", cl(dt)
	// reg coalgen c.rel_testN##c.rel_testN##c.rel_testN ire load load_sq c.dt i.hour i.dow if sample==1 & country=="`y'", cl(dt)

	margins, dydx(rel_testN)
   replace levels = r(b)[1,1] if country == "`y'"
	 replace bic_lev = -2*e(ll)+e(df_m)*log(e(N)) if country == "`y'"
	 
	 
	 // Fourth power specification
    reg lncoalgen c.rel_testN##c.rel_testN##c.rel_testN##c.rel_testN ire load load_sq i.month i.hour i.dow if sample==1 & country=="`y'", cl(dt)
	//   reg lncoalgen c.rel_testN##c.rel_testN##c.rel_testN##c.rel_testN ire load load_sq c.dt i.hour i.dow if sample==1 & country=="`y'", cl(dt)

    margins, dydx(rel_testN)
    replace fourth_power = r(b)[1,1] if country == "`y'"
    replace bic_fourth = -2*e(ll)+e(df_m)*log(e(N)) if country == "`y'"

    // Fifth power specification
    reg lncoalgen c.rel_testN##c.rel_testN##c.rel_testN##c.rel_testN##c.rel_testN ire load load_sq i.month i.hour i.dow if sample==1 & country=="`y'", cl(dt)
	//   reg lncoalgen c.rel_testN##c.rel_testN##c.rel_testN##c.rel_testN##c.rel_testN ire load load_sq c.dt i.hour i.dow if sample==1 & country=="`y'", cl(dt)

    margins, dydx(rel_testN)
    replace fifth_power = r(b)[1,1] if country == "`y'"
    replace bic_fifth = -2*e(ll)+e(df_m)*log(e(N)) if country == "`y'"
}

putexcel set marginal_SI1017, replace

putexcel A1 = "Country"
putexcel B1 = "Quadratic" 
putexcel C1 = "BIC_quad" 
putexcel D1 = "Linear" 
putexcel E1 = "BIC_lin"
putexcel F1 = "Levels" 
putexcel G1 = "BIC_levels" 
putexcel H1 = "Fourth Power"
putexcel I1 = "BIC_fourth"
putexcel J1 = "Fifth Power"
putexcel K1 = "BIC_fifth"
putexcel L1 = "Main" 
putexcel M1 = "BIC_main"

local myrow = 2
foreach y in "BG" "CZ" "DE" "DK" "ES" "FI" "GR" "HR" "HU" "IT" "IE" "NL" "PL" "RO" {

    putexcel A`myrow' = "`y'"
    tabstat quadratic if country=="`y'", save
    putexcel B`myrow' = matrix(r(StatTotal))
    tabstat bic_quad if country=="`y'", save
    putexcel C`myrow' = matrix(r(StatTotal))
    tabstat linear if country=="`y'", save
    putexcel D`myrow' = matrix(r(StatTotal))
    tabstat bic_lin if country=="`y'", save
    putexcel E`myrow' = matrix(r(StatTotal))
    tabstat levels if country=="`y'", save
    putexcel F`myrow' = matrix(r(StatTotal))
    tabstat bic_levels if country=="`y'", save
    putexcel G`myrow' = matrix(r(StatTotal))
    tabstat fourth_power if country=="`y'", save
    putexcel H`myrow' = matrix(r(StatTotal))
    tabstat bic_fourth if country=="`y'", save
    putexcel I`myrow' = matrix(r(StatTotal))
    tabstat fifth_power if country=="`y'", save
    putexcel J`myrow' = matrix(r(StatTotal))
    tabstat bic_fifth if country=="`y'", save
    putexcel K`myrow' = matrix(r(StatTotal))
    tabstat mainsp if country=="`y'", save
    putexcel L`myrow' = matrix(r(StatTotal))
    tabstat bic_main if country=="`y'", save
    putexcel M`myrow' = matrix(r(StatTotal))

    local myrow = `myrow' + 1
}



****SAMPLE PERIOD ROBUSTNESS CHECKS (Supp. FIG XX-XX)

gen period = .
// Initialize the period variable with missing values

// Period 2: April to December 2021
replace period = 2 if sample == 1 & year == 2021 & month >= 4 & month <= 12

// Period 3: April to October 2021 (exclude November and December)
replace period = 3 if sample == 1 & year == 2021 & month >= 4 & month <= 10

// Period 4: January to October 2021 (up to 10, exclude November and December)
replace period = 4 if sample == 1 & year == 2021 & month >= 1 & month <= 12

// Period 5: April 2021 to March 2022
replace period = 5 if sample == 1 & ((year == 2021 & month >= 4) | (year == 2022 & month <= 3))

// Check the distribution of period values to confirm no overlaps
tabulate period


foreach y in "BG" "CZ" "DE" "DK" "ES" "FI" "GR" "HR" "HU" "IT" "IE" "NL" "PL" "RO" {

	if "`y'"=="GR"{
	reg  lncoalgen c.rel_testN##c.rel_testN##c.rel_testN ire load load_sq c.dt i.hour i.dow if sample == 1 & ((year == 2021 & month >= 4) | (year == 2022 & month <= 1)) & country=="`y'",cl(dt)
	margins, dydx(rel_testN)
	local a=r(table)[rownumb(r(table),"b"),1]
		outreg2  using "sampledec2021.doc",  append addtext(Month FE, YES, Hour FE, YES, Day of Week FE, YES) keep(rel_testN c.rel_testN#c.rel_testN c.rel_testN#c.rel_testN#c.rel_testN ire load load_sq) label ctitle(`y') nocons bdec(3) sdec(3) addstat(Marginal Effect, `a')
	}
	else{
		if "`y'"=="BG"{
	reg  lncoalgen c.rel_testN##c.rel_testN##c.rel_testN ire load load_sq i.month i.hour i.dow if sample == 1 & ((year == 2021 & month >= 4) | (year == 2022 & month <= 1)) & country=="`y'",cl(dt)
	margins, dydx(rel_testN)
	local a=r(table)[rownumb(r(table),"b"),1]
			outreg2  using "sampledec2021.doc",  replace addtext(Month FE, YES, Hour FE, YES, Day of Week FE, YES) keep(rel_testN c.rel_testN#c.rel_testN c.rel_testN#c.rel_testN#c.rel_testN ire load load_sq) label ctitle(`y') nocons bdec(3) sdec(3) title("April 2021 - January 2022") addstat(Marginal Effect, `a')
		}
		else{
	reg  lncoalgen c.rel_testN##c.rel_testN##c.rel_testN ire load load_sq i.month i.hour i.dow if sample == 1 & ((year == 2021 & month >= 4) | (year == 2022 & month <= 1)) & country=="`y'",cl(dt)
	margins, dydx(rel_testN)
	local a=r(table)[rownumb(r(table),"b"),1]
			outreg2  using "sampledec2021.doc",  append addtext(Month FE, YES, Hour FE, YES, Day of Week FE, YES) keep(rel_testN c.rel_testN#c.rel_testN c.rel_testN#c.rel_testN#c.rel_testN ire load load_sq) label ctitle(`y') nocons bdec(3) sdec(3) addstat(Marginal Effect, `a')

		}
	}
}

foreach y in "BG" "CZ" "DE" "DK" "ES" "FI" "GR" "HR" "HU" "IT" "IE" "NL" "PL" "RO" {

	if "`y'"=="GR"{
	reg  lncoalgen c.rel_testN##c.rel_testN##c.rel_testN ire load load_sq c.dt i.hour i.dow if sample == 1 & year == 2021 & month >= 4 & month <= 11 & country=="`y'",cl(dt)
	margins, dydx(rel_testN)
	local a=r(table)[rownumb(r(table),"b"),1]
		outreg2  using "sampleoct2021.doc",  append addtext(Month FE, YES, Hour FE, YES, Day of Week FE, YES) keep(rel_testN c.rel_testN#c.rel_testN c.rel_testN#c.rel_testN#c.rel_testN ire load load_sq) label ctitle(`y') nocons bdec(3) sdec(3) addstat(Marginal Effect, `a')
	}
	else{
		if "`y'"=="BG"{
	reg  lncoalgen c.rel_testN##c.rel_testN##c.rel_testN ire load load_sq i.month i.hour i.dow if sample == 1 & year == 2021 & month >= 4 & month <= 11 & country=="`y'",cl(dt)
	margins, dydx(rel_testN)
	local a=r(table)[rownumb(r(table),"b"),1]
			outreg2  using "sampleoct2021.doc",  replace addtext(Month FE, YES, Hour FE, YES, Day of Week FE, YES) keep(rel_testN c.rel_testN#c.rel_testN c.rel_testN#c.rel_testN#c.rel_testN ire load load_sq) label ctitle(`y') nocons bdec(3) sdec(3) title("April 2021 - November 2021") addstat(Marginal Effect, `a')
		}
		else{
	reg  lncoalgen c.rel_testN##c.rel_testN##c.rel_testN ire load load_sq i.month i.hour i.dow if sample == 1 & year == 2021 & month >= 4 & month <= 11 & country=="`y'",cl(dt)
	margins, dydx(rel_testN)
	local a=r(table)[rownumb(r(table),"b"),1]
			outreg2  using "sampleoct2021.doc",  append addtext(Month FE, YES, Hour FE, YES, Day of Week FE, YES) keep(rel_testN c.rel_testN#c.rel_testN c.rel_testN#c.rel_testN#c.rel_testN ire load load_sq) label ctitle(`y') nocons bdec(3) sdec(3) addstat(Marginal Effect, `a')

		}
	}
}


foreach y in "BG" "CZ" "DE" "DK" "ES" "FI" "GR" "HR" "HU" "IT" "IE" "NL" "PL" "RO" {

	if "`y'"=="GR"{
	reg  lncoalgen c.rel_testN##c.rel_testN##c.rel_testN ire load load_sq c.dt i.hour i.dow if  sample == 1 & year == 2021 & month >= 1 & month <= 12 & country=="`y'",cl(dt)
	margins, dydx(rel_testN)
	local a=r(table)[rownumb(r(table),"b"),1]
		outreg2  using "samplejandec.doc",  append addtext(Month FE, YES, Hour FE, YES, Day of Week FE, YES) keep(rel_testN c.rel_testN#c.rel_testN c.rel_testN#c.rel_testN#c.rel_testN ire load load_sq) label ctitle(`y') nocons bdec(3) sdec(3) addstat(Marginal Effect, `a')
	}
	else{
		if "`y'"=="BG"{
	reg  lncoalgen c.rel_testN##c.rel_testN##c.rel_testN ire load load_sq i.month i.hour i.dow if sample == 1 & year == 2021 & month >= 1 & month <= 12 & country=="`y'",cl(dt)
	margins, dydx(rel_testN)
	local a=r(table)[rownumb(r(table),"b"),1]
			outreg2  using "samplejandec.doc",  replace addtext(Month FE, YES, Hour FE, YES, Day of Week FE, YES) keep(rel_testN c.rel_testN#c.rel_testN c.rel_testN#c.rel_testN#c.rel_testN ire load load_sq) label ctitle(`y') nocons bdec(3) sdec(3) title("January 2021 - December 2021") addstat(Marginal Effect, `a')
		}
		else{
	reg  lncoalgen c.rel_testN##c.rel_testN##c.rel_testN ire load load_sq i.month i.hour i.dow if sample == 1 & year == 2021 & month >= 1 & month <= 12 & country=="`y'",cl(dt)
	margins, dydx(rel_testN)
	local a=r(table)[rownumb(r(table),"b"),1]
			outreg2  using "samplejandec.doc",  append addtext(Month FE, YES, Hour FE, YES, Day of Week FE, YES) keep(rel_testN c.rel_testN#c.rel_testN c.rel_testN#c.rel_testN#c.rel_testN ire load load_sq) label ctitle(`y') nocons bdec(3) sdec(3) addstat(Marginal Effect, `a')

		}
	}
}



foreach y in "BG" "CZ" "DE" "DK" "ES" "FI" "GR" "HR" "HU" "IT" "IE" "NL" "PL" "RO" {

	if "`y'"=="GR"{
	reg  lncoalgen c.rel_testN##c.rel_testN##c.rel_testN ire load load_sq c.dt i.hour i.dow if sample == 1 & ((year == 2021 & month >= 4) | (year == 2022 & month <= 3)) & country=="`y'",cl(dt)
	margins, dydx(rel_testN)
	local a=r(table)[rownumb(r(table),"b"),1]
		outreg2  using "samplemarch22.doc",  append addtext(Month FE, YES, Hour FE, YES, Day of Week FE, YES) keep(rel_testN c.rel_testN#c.rel_testN c.rel_testN#c.rel_testN#c.rel_testN ire load load_sq) label ctitle(`y') nocons bdec(3) sdec(3) addstat(Marginal Effect, `a')
	}
	else{
		if "`y'"=="BG"{
	reg  lncoalgen c.rel_testN##c.rel_testN##c.rel_testN ire load load_sq i.month i.hour i.dow if sample == 1 & ((year == 2021 & month >= 4) | (year == 2022 & month <= 3)) & country=="`y'",cl(dt)
	margins, dydx(rel_testN)
	local a=r(table)[rownumb(r(table),"b"),1]
			outreg2  using "samplemarch22.doc",  replace addtext(Month FE, YES, Hour FE, YES, Day of Week FE, YES) keep(rel_testN c.rel_testN#c.rel_testN c.rel_testN#c.rel_testN#c.rel_testN ire load load_sq) label ctitle(`y') nocons bdec(3) sdec(3) title("April 2021 - March 2021") addstat(Marginal Effect, `a')
		}
		else{
	reg  lncoalgen c.rel_testN##c.rel_testN##c.rel_testN ire load load_sq i.month i.hour i.dow if sample == 1 & ((year == 2021 & month >= 4) | (year == 2022 & month <= 3)) & country=="`y'",cl(dt)
	margins, dydx(rel_testN)
	local a=r(table)[rownumb(r(table),"b"),1]
			outreg2  using "samplemarch22.doc",  append addtext(Month FE, YES, Hour FE, YES, Day of Week FE, YES) keep(rel_testN c.rel_testN#c.rel_testN c.rel_testN#c.rel_testN#c.rel_testN ire load load_sq) label ctitle(`y') nocons bdec(3) sdec(3) addstat(Marginal Effect, `a')

		}
	}
}

**New only the nov 2021-june 2022
foreach y in "BG" "CZ" "DE" "DK" "ES" "FI" "GR" "HR" "HU" "IT" "IE" "NL" "PL" "RO" {

	if "`y'"=="GR"{
	reg  lncoalgen c.rel_testN##c.rel_testN##c.rel_testN ire load load_sq c.dt i.hour i.dow if sample == 1 & ((year == 2021 & month >= 11) | (year == 2022 & month < 6)) & country=="`y'",cl(dt)
	margins, dydx(rel_testN)
	local a=r(table)[rownumb(r(table),"b"),1]
		outreg2  using "samplenovjune22.doc",  append addtext(Month FE, YES, Hour FE, YES, Day of Week FE, YES) keep(rel_testN c.rel_testN#c.rel_testN c.rel_testN#c.rel_testN#c.rel_testN ire load load_sq) label ctitle(`y') nocons bdec(3) sdec(3) addstat(Marginal Effect, `a')
	}
	else{
		if "`y'"=="BG"{
	reg  lncoalgen c.rel_testN##c.rel_testN##c.rel_testN ire load load_sq i.month i.hour i.dow if sample == 1 & ((year == 2021 & month >= 11) | (year == 2022 & month < 6)) & country=="`y'",cl(dt)
	margins, dydx(rel_testN)
	local a=r(table)[rownumb(r(table),"b"),1]
			outreg2  using "samplenovjune22.doc",  replace addtext(Month FE, YES, Hour FE, YES, Day of Week FE, YES) keep(rel_testN c.rel_testN#c.rel_testN c.rel_testN#c.rel_testN#c.rel_testN ire load load_sq) label ctitle(`y') nocons bdec(3) sdec(3) title("April 2021 - March 2021") addstat(Marginal Effect, `a')
		}
		else{
	reg  lncoalgen c.rel_testN##c.rel_testN##c.rel_testN ire load load_sq i.month i.hour i.dow if sample == 1 & ((year == 2021 & month >= 11) | (year == 2022 & month < 6)) & country=="`y'",cl(dt)
	margins, dydx(rel_testN)
	local a=r(table)[rownumb(r(table),"b"),1]
			outreg2  using "samplenovjune22.doc",  append addtext(Month FE, YES, Hour FE, YES, Day of Week FE, YES) keep(rel_testN c.rel_testN#c.rel_testN c.rel_testN#c.rel_testN#c.rel_testN ire load load_sq) label ctitle(`y') nocons bdec(3) sdec(3) addstat(Marginal Effect, `a')

		}
	}
}

**EDF 6
***Main Specification estimates of passthrough 

foreach y in "BG" "CZ" "DE" "DK" "ES" "FI" "GR" "HR" "HU" "IT" "NL" "PL" "RO" {

	if "`y'"=="GR"{
	reg electricity_prices price_gas c.dt i.hour i.dow ire c.load##c.load if country=="`y'" & sample==1,cl(dt)
		outreg2  using "passthorughsample.doc",  append addtext(Month FE, YES, Hour FE, YES, Day of Week FE, YES) keep(price_gas ire load) label ctitle(`y') nocons bdec(3) sdec(3) 
	}
	else{
		if "`y'"=="BG"{
	reg electricity_prices price_gas i.month i.hour i.dow ire c.load##c.load if country=="`y'" & sample==1,cl(dt)
		outreg2  using "passthorughsample.doc",  replace addtext(Month FE, YES, Hour FE, YES, Day of Week FE, YES) keep(price_gas ire load) label ctitle(`y') nocons bdec(3) sdec(3) 
		}
		else{
	reg electricity_prices price_gas i.month i.hour i.dow ire c.load##c.load if country=="`y'" & sample==1,cl(dt)
		outreg2  using "passthorughsample.doc",  append addtext(Month FE, YES, Hour FE, YES, Day of Week FE, YES) keep(price_gas ire load) label ctitle(`y') nocons bdec(3) sdec(3) 

		}
	}
}

**Robustness Check passthorugh sample (Supp. Fig XX-XX)
foreach y in "BG" "CZ" "DE" "DK" "ES" "FI" "GR" "HR" "HU" "IT" "NL" "PL" "RO" {
//foreach y in "BG" "RO" {
	reg electricity_prices price_gas i.month i.hour i.dow ire c.load##c.load if country=="`y'" & year>2020,cl(dt)
}

**SI Passthorugh ROBUSTNESS (2022)
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

	
**Supp. Fig. XX (Fig 2D no DE or PL)
graph box y_coal_lignite if sample==1 &country!="DE" &country!="PL",over(country,sort(1)) title("Coal Generation April 2021-June 2022") intensity(65) ylabel(,labsize(*1.3)) ytitle("MWh",size(*1.3)) asyvars nooutsides showyvars legend(off)


**Supp. Fig. XX (Revenue Difference)
graph hbar rev_dif, over(Country,sort(1) descending)  title("Difference between Revenue and Burden under Carbon Tax") intensity(65) ylabel(,labsize(*1.3)) ytitle("Euros (Thousands)",size(*1.3))   legend(off)


**Multivariate Tables of excesses, RRI against shares
*Supp. Fig X
robreg mm excess_price coal_share gas_share solar_share wind_share hydro_share,vce(robust) 
outreg2 using results_table4.doc, replace title("Multivariate regression results: Excess Price")  omit(scale)
robreg mm excess coal_share gas_share solar_share wind_share hydro_share,vce(robust) 
outreg2 using results_table4.doc, replace title("Multivariate regression results: Excess coal") 
robreg mm correl coal_share gas_share solar_share wind_share hydro_share,vce(robust) 
outreg2 using results_table4.doc, replace title("Multivariate regression results: Relative Responsiveness") 


***SI VERSIONS OF DIFFERENT ELASTICITY**** (Supp. Fig XX)

use elasticity_SI or in main.dta

replace elasticity=-0.05
replace change_electricityGenGasCap=change_gaspriceCap/avg_electricity*elasticity*avg_load*1000 if year==2022
replace change_electricityGenCarbonTax=change_electricityPriceCarbonTax/avg_electricity*elasticity*avg_load*1000 if year==2022
gen change_emissionsGasCapLow=change_electricityGenGasCap*emissions_fac*24*365/1000 if year==2022
gen change_emissionsCarbonTaxLow=change_electricityGenCarbonTax*emissions_fac*24*365/1000 if year==2022

replace elasticity=-0.35
replace change_electricityGenGasCap=change_gaspriceCap/avg_electricity*elasticity*avg_load*1000 if year==2022
replace change_electricityGenCarbonTax=change_electricityPriceCarbonTax/avg_electricity*elasticity*avg_load*1000 if year==2022
gen change_emissionsGasCapHigh=change_electricityGenGasCap*emissions_fac*24*365/1000 if year==2022
gen change_emissionsCarbonTaxHigh=change_electricityGenCarbonTax*emissions_fac*24*365/1000 if year==2022

//import excel "/Users/ZMarmarelis/Downloads/Fig4_elasticityrobust.xlsx", sheet("Sheet1") firstrow

*low elasticity
graph bar change_emissionsGasCapLow change_emissionsCarbonTaxLow if !missing(avg_electricity) & year==2022 ,over(country)  legend( label(1 "180 EUR/MWh Natural Gas Cap: Low Demand Elasticity") label(2 "Equivalent Carbon Tax: Low Demand Elasticity") ring(1) position(6))  ytitle("Output Effect Emissions (Ktonnes CO2/Year)",size(*0.9))  asyvars bar(2,color(purple)) bar(1,color(emerald)) intensity(50) name(EmissionsChangeElasticitiesLow,replace) title("A)",position(11)  size(*1))

*high elasticity
graph bar  change_emissionsGasCapHigh change_emissionsCarbonTaxHigh if !missing(avg_electricity) & year==2022,over(country)  legend( label(1 "180 EUR/MWh Natural Gas Cap: High Demand Elasticity") label(2 "Equivalent Carbon Tax: High Demand Elasticity") ring(1) position(6))  ytitle("Output Effect Emissions (Ktonnes CO2/Year)",size(*0.9))  asyvars bar(2,color(purple)) bar(1,color(emerald)) intensity(50) name(EmissionsChangeElasticitiesHigh,replace) title("B)",position(11)  size(*1))


**Or the below depending on which data file used (elasticity_SI)
replace change_electricityGenGasCap=change_electricityPriceGasCap/avg_electricity*elasticity*avg_load*1000
replace change_electricityGenCarbonTax=change_electricityPriceCarbonTax/avg_electricity*elasticity*avg_load*1000
gen change_emissionsGasCapLow=change_electricityGenGasCap*emissions_fac*24*365/1000
gen change_emissionsCarbonTaxLow=change_electricityGenCarbonTax*emissions_fac*24*365/1000

replace elasticity=-0.35
replace change_electricityGenGasCap=change_electricityPriceGasCap/avg_electricity*elasticity*avg_load*1000
replace change_electricityGenCarbonTax=change_electricityPriceCarbonTax/avg_electricity*elasticity*avg_load*1000
gen change_emissionsGasCapHigh=change_electricityGenGasCap*emissions_fac*24*365/1000
gen change_emissionsCarbonTaxHigh=change_electricityGenCarbonTax*emissions_fac*24*365/1000

// *Save to excel
// putexcel set Fig4_elasticityrobust, replace
// putexcel A1 = "Country"
// putexcel B1= "Emissiosn Change Gas Cap Low" 
// putexcel C1= "Emissiosn Change Carbon Tax Low" 
// putexcel D1= "Emissiosn Change Gas Cap High" 
// putexcel E1= "Emissiosn Change Carbon Tax High" 

// local myrow = 2
// foreach y in "BG" "CZ" "DE" "DK" "ES" "FI" "GR" "HR" "HU" "IT" "NL" "PL" "RO" {

// 	putexcel A`myrow' = "`y'"
// 	tabstat  change_emissionsGasCapLow if country=="`y'" &year==2022,save
// 	putexcel B`myrow' = matrix(r(StatTotal))
// 	tabstat  change_emissionsCarbonTaxLow if country=="`y'"  &year==2022,save
// 	putexcel C`myrow' = matrix(r(StatTotal))
// 	tabstat  change_emissionsGasCapHigh if country=="`y'"  &year==2022,save
// 	putexcel D`myrow' = matrix(r(StatTotal))
// 	tabstat  change_emissionsCarbonTaxHigh if country=="`y'"  &year==2022,save
// 	putexcel E`myrow' = matrix(r(StatTotal))
// 	local myrow = `myrow' + 1
// }

// import excel "/Users/ZMarmarelis/Downloads/Fig4_elasticityrobust.xlsx", sheet("Sheet1") firstrow

// **low elasticity
// graph bar EmissiosnChangeGasCapLow EmissiosnChangeCarbonTaxLow  ,over(Country)  legend( label(1 "180 EUR/MWh Natural Gas Cap: Low Demand Elasticity") label(2 "Equivalent Carbon Tax: Low Demand Elasticity") ring(1) position(6))  ytitle("Output Effect Emissions (Ktonnes CO2/Year)",size(*0.9))  asyvars bar(2,color(purple)) bar(1,color(emerald)) intensity(50) name(EmissionsChangeElasticitiesLow,replace) title("A)",position(11)  size(*1))

// **high elasticity 
// graph bar  EmissiosnChangeGasCapHigh EmissiosnChangeCarbonTaxHigh ,over(Country)  legend( label(1 "180 EUR/MWh Natural Gas Cap: High Demand Elasticity") label(2 "Equivalent Carbon Tax: High Demand Elasticity") ring(1) position(6))  ytitle("Output Effect Emissions (Ktonnes CO2/Year)",size(*0.9))  asyvars bar(2,color(purple)) bar(1,color(emerald)) intensity(50) name(EmissionsChangeElasticitiesHigh,replace) title("B)",position(11)  size(*1))

// // 	gen total_emissionsCapLow=-sub+EmissiosnChangeGasCapLow
// // 	gen total_emissionsTaxLow=EmissiosnChangeCarbonTaxLow-sub 
// // 	gen total_emissionsCapHigh=-sub+EmissiosnChangeGasCapHigh
// // 	gen total_emissionsTaxHigh=EmissiosnChangeCarbonTaxHigh-sub 

// graph bar total_emissionsCapLow total_emissionsTaxLow ,over(Country) legend( label(1 "180 EUR/MWh Natural Gas Cap: Low Demand Elasticity") label(2 "Equivalent Carbon Tax: Low Demand Elasticity") ring(1) position(6))  ytitle("Total Emissions Change (Ktonnes CO2/Year)",size(*0.9)) asyvars bar(2,color(khaki)) bar(1,color(ebblue)) intensity(50) name(TotalL,replace) title("C)",position(11)  size(*1))

// graph bar total_emissionsCapHigh total_emissionsTaxHigh ,over(Country) legend( label(1 "180 EUR/MWh Natural Gas Cap: High Demand Elasticity") label(2 "Equivalent Carbon Tax: High Demand Elasticity") ring(1) position(6))  ytitle("Total Emissions Change (Ktonnes CO2/Year)",size(*0.9)) asyvars bar(2,color(khaki)) bar(1,color(ebblue)) intensity(50) name(TotalH,replace) title("D)",position(11)  size(*1))

// //graph combine  EmissionsChangeElasticitiesLow EmissionsChangeElasticitiesHigh TotalL TotalH,name(elasticities,replace) 
// graph combine  EmissionsChangeElasticitiesLow EmissionsChangeElasticitiesHigh,name(elasticities,replace)  altshrink


**Unused
use emissions_long
graph bar emissions, over(year) by(country,yrescale) ytitle("Mtonnes CO2") legend(off) intensity(50) bar(1,color(purple*0.5))  bar(2,color(purple*0.5))  bar(3,color(purple*0.5))  bar(4,color(purple*0.5))  bar(5,color(purple*0.5))  bar(6,color(dkorange*0.7)) asyvars showyvars 


