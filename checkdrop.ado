capture program drop checkdrop
*! version 1.0
program define checkdrop, rclass
    version 14.0
	* check if variables exist in a dataset, drop them if they do with a message
    syntax anything [, dataset(string)]
    
    // If dataset name not provided, use "dataset" as default
    if "`dataset'" == "" {
        local dataset "dataset"
    }

    local dropped_count 0
    local dropped_vars ""
    
    // Split the input string into individual variable names
    local varnames: word count `anything'
    forvalues i = 1/`varnames' {
        local varname: word `i' of `anything'
        
        capture confirm variable `varname'
        if _rc == 0 {
            local dropped_count = `dropped_count' + 1
            local dropped_vars `dropped_vars' `varname'
            display as text "`varname' already in `dataset'. Dropping `varname'"
            drop `varname'
        }
    }

    return scalar dropped_count = `dropped_count'
    return local dropped_vars "`dropped_vars'"
    return local dataset "`dataset'"
end
