capture program drop extrname_clean
program define extrname_clean
    syntax varname
    local name: word 1 of `varlist'
    
	* drop extrname variables just in case
	capture drop last first suffix affil odd middle
	
    * run extrname directly with all option
    qui extrname `name', all
    
    * preserve the original data after extrname
    tempvar orig_first orig_last orig_middle orig_suffix orig_odd
    foreach var in first last middle suffix odd {
        qui gen `orig_`var'' = `var'
    }
    
    * create indicator for changes
    gen byte extrname_clean = 0
    
    * convert all name components to uppercase at the beginning
    qui foreach var in first middle last {
        replace `var' = upper(`var')
    }
    
    * process the names
    qui {
        // Match full names after comma (case insensitive)
        replace extrname_clean = 1 if regexm(`name', "(?i), *(ED|AL|MO|BO|OZ|JO|TY|AJ|RO|CY)( |$|,)") & odd == 21
        replace first = regexs(1) if regexm(`name', "(?i), *(ED|AL|MO|BO|OZ|JO|TY|AJ|RO|CY)( |$|,)") & odd == 21
        replace middle = "" if regexm(`name', "(?i), *(ED|AL|MO|BO|OZ|JO|TY|AJ|RO|CY)( |$|,)") & odd == 21
        
        // Match full names at start (case insensitive)
        replace extrname_clean = 1 if regexm(`name', "(?i)^(ED|AL|MO|BO|OZ|JO|TY|AJ|RO|CY)( |$|,)") & odd == 21
        replace first = regexs(1) if regexm(`name', "(?i)^(ED|AL|MO|BO|OZ|JO|TY|AJ|RO|CY)( |$|,)") & odd == 21
        replace middle = "" if regexm(`name', "(?i)^(ED|AL|MO|BO|OZ|JO|TY|AJ|RO|CY)( |$|,)") & odd == 21
        
        // Van/Von processing (case insensitive) - with space
        local vv_pattern "(?i), +(VAN|VON)( |$)"
        replace extrname_clean = 1 if regexm(`name', "`vv_pattern'") & odd == .
        replace first = regexs(1) if regexm(`name', "`vv_pattern'") & odd == .
        replace last = subinstr(last, upper(regexs(1)), "", 1) if regexm(`name', "`vv_pattern'") & odd == .
        
        // Handle standalone Van/Von at start of name - with space
        replace extrname_clean = 1 if first == "" & regexm(`name', "(?i)^(VAN|VON)( |$)") & odd == .
        replace first = upper(regexs(1)) if first == "" & regexm(`name', "(?i)^(VAN|VON)( |$)") & odd == .
        replace last = subinstr(upper(last), upper(regexs(1)), "", 1) if first == upper(regexs(1)) & odd == .
        
        // Mac processing (case insensitive) - no space
        local mac_pattern "(?i), +(MAC)( |$)"
        replace extrname_clean = 1 if regexm(`name', "`mac_pattern'")
        replace first = upper(regexs(1)) if regexm(`name', "`mac_pattern'")
        replace last = subinstr(upper(last), "MAC", "", 1) if first == "MAC"
        
        // Handle standalone Mac at start of name - no space
        replace extrname_clean = 1 if first == "" & regexm(`name', "(?i)^(MAC)( |$)")
        replace first = upper(regexs(1)) if first == "" & regexm(`name', "(?i)^(MAC)( |$)")
        replace last = subinstr(upper(last), "MAC", "", 1) if first == "MAC"
    }
    
	replace last = strtrim(last)
	 qui foreach var in first middle last {
        replace `var' = upper(`var')
    }
    * label the indicator variable
    label var extrname_clean "1 if name was modified by name pattern matching or van/von/mac cleaning"
    
    * optional: Add a note to the dataset
    notes: Names processed with extrname_clean (including extrname,all) on $S_DATE
end
