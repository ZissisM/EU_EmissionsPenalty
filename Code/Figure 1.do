*Figure 1 panels* B,C,D,E

use main

cap egen mean_elec=mean(electricity_prices) if sample==1 & !missing(electricity_prices),by(t)
cap egen elec_ma=mean(mean_elec) if sample==1,by(date)

cap egen avg_co=mean(y_coal_lignite) if sample==1,by(t)
cap egen avg_coallig=mean(avg_co) if sample==1,by(date)

tw line avg_coallig t if sample==1,sort


**Greece is just randomly selected, here all countries have same data 

**Panel D
**Create lines for averages overlaid: baselines and march 2022
cap drop yline xline
gen yline=45 if dt >= 22371 & dt <= 22401
gen xline = dt if !missing(yline)

cap drop yline2 xline2
gen yline2=74 if dt >= 22701 & dt <= 22736
cap gen xline2 = dt if !missing(yline2)

tw line price_carbon dt if sample==1 & country=="GR", sort xlabel(22371 22431 22492 22553 22614 22675 22736 22797, format(%tdMon-CCYY)) xtitle("") ytitle("Carbon price (EUR/ton CO2)",size(*1.2)) lwidth(*1.4) lcolor(emerald*0.8) name(c,replace)  title("D)",position(11) size(*1.4)) text(47 22384 "45€", color(black)) text(76 22717 "75€", color(black)) legend(off) || (line yline xline if !missing(yline), lwidth(*2) lcolor(black))  || (line yline2 xline2 if !missing(yline2), lwidth(*2) lcolor(black)) 
graph export "fig1d.svg", as(svg) width(3000) replace



**Panel C
cap drop yline xline
gen yline=7 if dt >= 22371 & dt <= 22401
gen xline = dt if !missing(yline)

cap drop yline2 xline2
gen yline2=40 if dt >= 22701 & dt <= 22736
cap gen xline2 = dt if !missing(yline2)

tw line price_coal dt if sample==1 & country=="GR", sort xlabel(22371 22431 22492 22553 22614 22675 22736 22797, format(%tdMon-CCYY)) xtitle("") ytitle("Coal price (EUR/MWh)",size(*1.2)) lwidth(*1.4) lcolor(sienna*0.8) name(co,replace) title("C)",position(11) size(*1.4)) legend(off) text(9 22384 "7€", color(black)) text(42 22717 "40€", color(black)) || (line yline xline if !missing(yline), lwidth(*2) lcolor(black))  || (line yline2 xline2 if !missing(yline2), lwidth(*2) lcolor(black)) 
graph export "fig1c.svg", as(svg) width(3000) replace


**Panel E
cap drop yline xline
gen yline=82 if dt >= 22371 & dt <= 22401
gen xline = dt if !missing(yline)

cap drop yline2 xline2
gen yline2=245 if dt >= 22701 & dt <= 22736
cap gen xline2 = dt if !missing(yline2)

tw line elec_ma dt if sample==1, sort xlabel(22371 22431 22492 22553 22614 22675 22736 22797, format(%tdMon-CCYY)) xtitle("") ytitle("Average Wholesale Electricity Price (EUR/MWh)",size(*1.2)) lwidth(*1.4) lcolor(dkorange*0.75) name(el,replace) title("E)",position(11) size(*1.4)) legend(off)  text(95 22384 "82€", color(black)) text(260 22717 "245€", color(black)) || (line yline xline if !missing(yline), lwidth(*2) lcolor(black))  || (line yline2 xline2 if !missing(yline2), lwidth(*2) lcolor(black)) 
graph export "fig1e.svg", as(svg) width(3000) replace

**Panel B
cap drop yline xline
gen yline=2817 if dt >= 22371 & dt <= 22401
gen xline = dt if !missing(yline)

cap drop yline2 xline2
gen yline2=4005 if dt >= 22701 & dt <= 22736
cap gen xline2 = dt if !missing(yline2)


tw line avg_coallig dt if sample==1 & country=="GR", sort xlabel(22371 22431 22492 22553 22614 22675 22736 22797, format(%tdMon-CCYY)) title("B)",position(11) size(*1.4)) xtitle("") ytitle("Average Coal Generation (MWh)",size(*1.2)) lwidth(*1.2) lcolor(maroon*0.75) name(cos,replace) legend(off)  text(2910 22384 "2817", color(black)) text(4110 22717 "4005", color(black)) || (line yline xline if !missing(yline), lwidth(*2) lcolor(black))  || (line yline2 xline2 if !missing(yline2), lwidth(*2) lcolor(black)) 
graph export "fig1b.svg", as(svg) width(3000) replace




