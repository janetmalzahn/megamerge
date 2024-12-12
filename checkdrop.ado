capture program drop checkdrop
*! version 1.0
program define checkdrop
    version 14.0
	* check if variables exist in a dataset, drop them if they do with a message
    syntax anything [, dataset(string)]
    
    // If dataset name not provided, use "dataset" as default
    if "`dataset'" == "" {
        local dataset "dataset"
    }
    
    // Split the input string into individual variable names
    local varnames: word count `anything'
    forvalues i = 1/`varnames' {
        local varname: word `i' of `anything'
        
        capture describe `varname', varlist
		di "`r(varlist)'"
		di _rc
        if _rc == 0 {
            // Only drop if it's an exact match
            if "`r(varlist)'" == "`varname'" {
                display as text "`varname' already in `dataset'. Dropping `var'"
                drop `varname'
            }
        }
    }
end
