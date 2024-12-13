**Figure 4 



use excess_scat 
**Relative Respsonsiveness
foreach y "BG" "CZ" "DE" "DK" "ES" "FI" "HR" "HU" "IT" "IE"  "NL" "PL" "RO"{
//foreach y in  "GR"  {

    * Run regression for coal responsiveness
    reg lncoalgen c.rel_testN##c.rel_testN##c.rel_testN##i.hour ire load load_sq i.dow c.dt if sample == 1 & country == "`y'", cl(dt)
    eststo `y'c: margins, dydx(rel_testN) at(hour=(0(1)23)) vsquish post
	esttab using coalc.csv, replace wide plain mtitles label noobs 

    * Run regression for electricity price pass-through
    reg electricity_prices price_gas ire c.load##c.load c.price_gas#i.hour i.hour c.dt i.dow#i.hour if sample == 1 & country == "`y'", cl(dt)
    eststo `y'p:margins, dydx(price_gas) at(hour=(0(1)23)) vsquish post
	esttab using coalp.csv, replace wide plain mtitles label noobs 
}


**Calculate correlations in Excel and save as correl variable and import into dataset

graph hbar correl if !missing(correl),over(labels, sort(1)) ytitle("Relative Responsiveness") bar(1, color(maroon%80)) ylabel(,labsize(*1.4)) name(corrs,replace) title("A)",size(*1.3) pos(11))
graph export Fig4A.svg, as(svg) width(2400)



robreg mm correl coal_share if exclude==0
matrix b=e(b)
cap gen z7=1 
replace z7= 9 if Country=="FI"
replace z7= 1 if Country=="ES"
replace z7= 9 if Country=="IT"
replace z7= 1 if Country=="HU"
replace z7= 1 if Country=="RO"
replace z7= 3 if Country=="DE"
replace z7= 1 if Country=="GR"

twoway scatter correl coal_share if exclude==0, mlabel(labels)  mlabvposition(z7) mlabsize(*1.5) msymbol(d) mcolor(maroon%75) msize(*1.5) color(navy) graphregion(lstyle(none)) title("B)",position(11) size(*1.4)) xtitle("Coal share",size(*1.47)) ylabel(,labsize(*1.6) grid gmax gmin glwidth(0.5)) legend(off) xlabel(,labsize(*1.5)) ytitle("Relative Responsiveness",size(*1.4)) name(coalcorr,replace) || function y=_b[coal_share]*x+_b[_cons],range(coal_share) || lfit correl coal_share if exclude==0, lcolor(ebblue*0.5) 
graph export Fig4B.svg, as(svg) width(2400)



robreg mm correl decarb_share if exclude==0
matrix b=e(b)
cap gen z7=1 
replace z7= 10 if Country=="DK"
replace z7= 9 if Country=="HR"
replace z7= 4 if Country=="ES"

twoway scatter correl decarb_share if exclude==0, mlabel(labels) mlabvposition(z7) mlabsize(*1.5) msymbol(d) mcolor(maroon%75) msize(*1.5) color(navy) graphregion(lstyle(none)) title("C)",position(11) size(*1.4)) xtitle("Decarbonized share",size(*1.47)) ylabel(,labsize(*1.6) grid gmax gmin glwidth(0.5)) legend(off) xlabel(,labsize(*1.5)) ytitle("Relative Responsiveness",size(*1.4)) name(decorr,replace) || function y=_b[decarb_share]*x+_b[_cons],range(decarb_share) || lfit correl decarb_share if exclude==0, lcolor(ebblue*0.5) 
graph export Fig4C.svg, as(svg) width(2400)


**Combine all in powerpoint to make Figure 4
