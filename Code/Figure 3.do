
// egen coal_hour = mean(y_coal_lignite), by(country hour)
// egen coal_hourS =mean(y_coal_lignite_pct), by(country hour)
// drop ire_hour ire_hourS cap_ire irecf irecf_hour
// gen ire_s=ire/load
// egen ire_hourS=mean(ire_s) if sample==1,by(country hour)
// egen ire_hour =mean(ire)  if sample==1, by(country hour)
// egen load_hour=mean(load), by(country hour)
// egen cap_ire=max(ire) if sample==1, by(country)
// egen cap_coal=max(y_coal_lignite),by(country)
// gen coal_left=cap_coal-y_coal_lignite
// egen coal_left_hour=mean(coal_left),by(country hour)
// egen cap_hydro=max(y_hydro) if sample==1, by(country)
// egen hydrocf_hour=mean(hydro_cf), by(country hour)
// cap gen coal_share=y_coal_lignite/total
// cap gen hydro_share=y_hydro/total
// gen nuc_share=y_nuclear/total
// egen coal_share_hour=mean(coal_share) if sample==1,by(country hour)
// egen hydro_share_hour=mean(hydro_share) if sample==1,by(country hour)
// egen gas_share_hour=mean(gas_share) if sample==1,by(country hour)
// egen ire_share_hour=mean(ire_share) if sample==1,by(country hour)
// egen nuc_share_hour=mean(nuc_share) if sample==1,by(country hour)
// label var coal_share_hour  "Coal"
// label var gas_share_hour "Natural Gas"
// label var hydro_share_hour  "Hydro"
// label var ire_share_hour  "IRE"
// label var nuc_share_hour  "Nuclear"


**Figure 4 panels**


//foreach y in "BG" "CZ" "DE" "DK" "ES" "GR" "FI"  "HR" "HU" "IT" "NL" "PL" "RO" {
	
//Figure 4
foreach y in "CZ" "PL" "DE" "FI" "ES"{
//foreach y in "GR"{
**These ones go in SI:
//foreach y in "BG" "DK" "ES" "GR" "FI" "PL" {


	reg  lncoalgen c.rel_testN##c.rel_testN##c.rel_testN##i.hour ire load load_sq i.dow i.month if sample == 1 & country == "`y'", cl(dt)
	//IF GR
	//reg lncoalgen c.rel_testN##c.rel_testN##c.rel_testN##i.hour ire load load_sq i.dow c.dt if sample == 1 & country == "`y'", cl(dt)

	margins, dydx(rel_testN) at(hour=(0(1)23)) vsquish post  
	coefplot, vertical recast(connected) msize(*1.3) lwidth(*1.2)  mlabel(cond(@pval<.01, "***", cond(@pval<.05, "**", ""))) xlabel(1 "0"  5 "4" 9 "8" 13 "12" 17 "16" 21 "20" 24 "23",labsize(*1.81) grid gmax gmin) mlabsize(large) xtitle("Hour of day",size(*1.81)) ytitle("Average Coal Responsiveness",size(*1.81)) title("",size(*0.92) position(11)) mcolor(%75) msymbol(d) mfcolor(white) levels(95) ciopts(recast(. rcap) color(*0.65)) yline(0, lwidth(*2.1)) yline(1, lwidth(*2.1)) xscale(range(1 24)) name(`y'CBeforel, replace) ylabel(,labsize(*1.81) grid gmax gmin)  grid(gmax gmin glpattern(dot) glcolor(gray) glwidth(*0.3)) title("A)",size(*1.4))

	//IF GR
	//reg electricity_prices price_gas ire c.load##c.load c.price_gas#i.hour c.dt i.hour i.dow#i.hour  if sample==1 & country == "`y'", cl(dt)

	reg electricity_prices price_gas ire c.load##c.load c.price_gas#i.hour i.month#i.hour i.dow#i.hour  if sample==1 & country == "`y'", cl(dt)
	margins, dydx(price_gas) at(hour=(0(1)23)) vsquish post noestimcheck 
	coefplot, vertical recast(connected) msize(*1.3) lwidth(*1.2)  mlabel(cond(@pval<.01, "***", cond(@pval<.05, "**", ""))) xlabel(1 "0"  5 "4" 9 "8" 13 "12" 17 "16" 21 "20" 24 "23",labsize(*1.81) grid gmax gmin) mlabsize(large) xtitle("Hour of day",size(*1.81)) ytitle("Average Pass-through",size(*1.81)) title("",size(*0.92) position(11)) mcolor(%75) msymbol(d) mfcolor(white) levels(95) ciopts(recast(. rcap) color(*0.65)) yline(0, lwidth(*2.1)) yline(1, lwidth(*2.1)) xscale(range(1 24)) name(`y'PBefore, replace) ylabel(,labsize(*1.81) grid gmax gmin)  grid(gmax gmin glpattern(dot) glcolor(gray) glwidth(*0.3)) title("B)",size(*1.4))

	twoway connected coal_share_hour gas_share_hour hydro_share_hour ire_share_hour nuc_share_hour hour if country=="`y'" & sample==1, xscale(range(1 24)) clcolor(sienna*0.7 midgreen*0.7 orange*0.6 red*0.7 midblue*0.6 dknavy*0.7) mcolor(sienna*0.6 midgreen*0.6 orange*0.5 red*0.6 midblue*0.5 dknavy*0.6) msymbol(D ..) xlabel(0 4 8 12 16 20 23) sort title("",size(*0.95) position(11)) xtitle("Hour of day",size(*1.81)) ytitle("Energy Share ",size(*1.6))  name(`y'Shares,replace) xlabel(,labsize(*1.81)) legend(pos(6) row(2) size(*1.5))  ylabel(,labsize(*1.81)) || line load_hour hour if country=="`y'", yaxis(2) sort lpattern("-") ytitle("Load (GWh)",axis(2) size(*1.81))  ylabel(,labsize(*1.81) axis(2))lwidth(*2.3)  title("C)",size(*1.4))

	graph combine `y'CBeforel `y'PBefore `y'Shares,altshrink name(`y') rows(1) scale(0.88) title(`y',size(*1.3))
	graph export Fig3_`y'.svg, as(svg) width(2400)
}

**Edited further in Powerpoint
