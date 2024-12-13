
use prices_2022
cap drop diff carbon_tax temp temp_mean
cap drop diff carbon_tax
gen diff = .
gen carbon_tax = .

local min_diff = 10
local optimal_tax = .
forval i = 100(1)20000 {
    local x = `i' / 1000
    quietly gen temp = (price_gas + `x'*0.37*0.3+price_carbon*0.37*0.3) / (coal_p + (price_carbon+`x')*0.3)
    quietly egen temp_mean = mean(temp)
	*2.247722 is new price after carbon conversion
    quietly replace diff = abs(temp_mean - 2.247722) 

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

replace carbon_tax=12.18
replace rel_test_carbonTax=(price_gas+price_carbon*0.37*0.3+carbon_tax*0.37*0.3)/(coal_p+carbon_tax*0.3+price_carbon*0.3)

*Test and find the actual right one!
sum rel_test_carbonTax rel_gascapN if year==2022
*Same!! (what we wanted!)
