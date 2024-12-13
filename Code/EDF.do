

***EDF 1
*Relative responsiveness index relationship with change in wholesale electricity price under the two different policies
use excess_scat
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
*Main estimates 
use excess_scat
graph hbar dC dP if !missing(correl),over(labels, sort(1)) ytitle("Average Intensity") bar(1, color(maroon%80)) bar(2, color(emerald%80)) ylabel(,labsize(*1.4)) name(intens,replace) title("",size(*1.3) pos(11)) legend(order(1 "Coal Respsonsiveness" 2 "Price Pass-through"))



***EDF 3
*Energy Shares Illustration per Country 
use excess_scat
graph hbar solar_share wind_share hydro_share nuc_share gas_share coal_share other_share, stack over(labels, label(labsize(*0.95))) ///
		//sort(order))  ysize(6) xsize(8) ///
		ytitle("Share of generation mix (April 2021-June 2022)") graphregion(margin(l+18)) ///
		bar(1, color(orange*0.6)) bar(2, color(midgreen*0.6)) bar(3, color(red*0.6)) ///
		bar(4, color(midblue*0.6)) bar(5, color(sienna*0.5)) bar(6, color(dknavy*0.6)) title("",size(*1.2) position(11)) ylabel(,labsize(*1.1)) legend((1 "Solar") (2 "Wind") (3 "Hydro") (4 "Nuclear") (5 "Natural Gas") (6 "Coal") size(small) position(6) rows(2)) 

		
		
**EDF 4 
*Relative responsiveness index broken down by decarbonized shares
use excess_scat
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

		

*Main speicication estimates of coal responsiveness
**EDF 5
use main
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


**EDF 6
***Main Specification estimates of passthrough 
use main
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
