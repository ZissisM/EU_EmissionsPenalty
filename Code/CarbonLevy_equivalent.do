
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



***Possible Exploratory***
// use prices_2022,clear

// local min_diff = 10
// local optimal_tax = .

// // Start the loop and save results to the new dataset structure
// forval i = 100(1)10000 {
//     local x = `i' / 1000
    
//     // --- (Original Calculation Step) ---
//     // Use the original data for these calculations:
//     quietly gen temp2 = (price_gas + `x'*0.37*0.3 + price_carbon*0.37*0.3) / (coal_p + (price_carbon+`x')*0.3)
//     quietly egen temp_mean2 = mean(temp2)
//     quietly gen diff2 = abs(temp_mean2[1] - 2.247722) // Use [1] since temp_mean is constant

//     // Store the results in the temporary variables
//     local current_diff = diff2[1]
    
//     // --- (Store Data Points for Graph) ---
//     // Save the tax and difference into the new dataset structure (using the observation `k`)
//     preserve // Temporarily save the current dataset state
//     // Switch to a simple dataset with two variables for storage
//     clear
//     set obs 1
//     gen tax_value = `x'
//     gen abs_diff = `current_diff'
    
//     // Append this single observation to a running results file
//     if `i' == 100 {
//         save Calibration_Results, replace
//     }
//     else {
//         append using Calibration_Results
//         save Calibration_Results, replace
//     }
//     restore // Return to the original dataset
    
//     // --- (Optimization Logic - Same as before) ---
//     if `current_diff' < `min_diff' {
//         local min_diff = `current_diff'
//         local optimal_tax = `x'
//     }
    
//     // Clean up temporary variables in the original data
//     drop temp2 temp_mean2 diff2
// }

// Load the final results dataset
// use Calibration_Results, clear


// // Create the scatter plot
// twoway (scatter abs_diff tax_value, msize(tiny) color(midblue) sort) ///
//        (line abs_diff tax_value, color(midblue) lwidth(medium)),   ///
//        title("Calibration of Cap-Equivalent Carbon Price")        ///
//        ytitle("Absolute Difference from Target Relative Price")   ///
//        xtitle("Hypothetical Additional Carbon Tax (EUR/tonne CO2)") ///
//        legend(off)
       
// // Add a vertical line at the optimal tax (12.18) and a horizontal line at 0 difference
// gr_edit .plotregion1.plot1.AddVerticalLine `optimal_tax', color(red) lpattern(dash)
// gr_edit .plotregion1.plot1.AddHorizontalLine 0, color(black) lpattern(solid)

// // Label the optimal point
// // Note: This labeling can be tricky. You might use the `label` option on a marked point.
// // A simpler way is to use the `text()` option:
// // twoway ... (line...) text(0.001 12.18 "Optimal Tax: 12.18 EUR", place(e)), ...

// graph export Calibration_Figure.png, replace
