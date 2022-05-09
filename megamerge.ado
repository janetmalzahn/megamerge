capture program drop megamerge
program define megamerge

* define version number
version 15.1

* define the syntax
syntax varlist using/ [,replace(string) trywithout(string)]

* arguments: master using varlist
** master = master dataset
** using = using dataset
** varlist = varlist for merge 

*****************************
* Generate initial and lasts
*****************************

* initial duplicates for master

* get first initial
capture gen initial = substr(first,1,1)


* get parts of last name 
split last, gen(last) // split last name into each part
gen last_parts = length(last) - length(subinstr(last, " ", "", .)) + 1 // get number of last name parts 
quietly summarize(last_parts) // enable r(max)
local n `r(max)' // store r(max)
gen last_last = last1 // instantiate last_last
forvalues x = 1/`n'{
	replace last_last = last`x' if last`x' != "" // replace last_last with last
}

* gets hyphen parts of lastname 
split last, parse("-") generate(hyphen) // split by hyphen
gen hyphen_parts = length(last) - length(subinstr(last, "-", "", .)) + 1 // get number of hyphen parts
quietly summarize(hyphen_parts) // enable r(max)
local n `r(max)' // store r(max)
gen hyphen_last = hyphen1 // instantiate last_last
forvalues x = 1/`n'{
	replace hyphen_last = hyphen`x' if hyphen`x' != "" // replace last_last with last
}

* save the using data
tempfile master
save `master'

use `using', clear

* get first initial
capture gen initial = substr(first,1,1)

* get parts of last name 
split last, gen(last) // split last name into each part
gen last_parts = length(last) - length(subinstr(last, " ", "", .)) + 1 // get number of last name parts 
quietly summarize(last_parts) // enable r(max)
local n `r(max)' // store r(max)
gen last_last = last1 // instantiate last_last
forvalues x = 1/`n'{
	replace last_last = last`x' if last`x' != "" // replace last_last with last
}

* gets hyphen parts of lastname 
split last, parse("-") generate(hyphen) // split by hyphen
gen hyphen_parts = length(last) - length(subinstr(last, "-", "", .)) + 1 // get number of hyphen parts
quietly summarize(hyphen_parts) // enable r(max)
local n `r(max)' // store r(max)
gen hyphen_last = hyphen1 // instantiate last_last
forvalues x = 1/`n'{
	replace hyphen_last = hyphen`x' if hyphen`x' != "" // replace last_last with last
}

* save the using data
tempfile using_data
save `using_data'


**************************
* Get rid of duplicates 
**************************

use `using_data', clear

* tag initial duplicates in using
duplicates tag `varlist' last_last first, gen(dup)
drop if dup == 0 // keep only duplicates
drop dup
tempfile first_duplicates_using // create tempfile with duplicates
save `first_duplicates_using' // save tempfile with duplicates

* save using without the duplicates
use `using_data'
duplicates tag `varlist' last_last first, gen(dup) // tag duplciates
drop if dup > 0 // keep only unique observations
drop dup
tempfile using_nodups // create tempfile without the duplicates
save `using_nodups'

* use duplicates
use `master', clear

* save dataset with extra duplicates
duplicates tag `varlist' last_last first, gen(dup)
tab dup
drop if dup == 0
drop dup
tempfile first_duplicates_master
save `first_duplicates_master'

* get master without duplicates 
use `master'
duplicates tag `varlist' last_last first, gen(dup)
drop if dup != 0
drop dup

* Zeroth Pass: merge with last and first
************************************************************************
merge 1:1 `varlist' last_last first using `using_nodups'
tempfile merge_first
save `merge_first'

keep if _merge == 3
tempfile merge_matched
save `merge_matched'

use `merge_first'
keep if _merge == 2
drop _merge
tempfile using_merge_unmatched
save `using_merge_unmatched'

* tag duplicates in using
duplicates tag `varlist' last_last initial, gen(dup)
drop if dup == 0 // keep only duplicates
drop dup
tempfile initial_duplicates_using // create tempfile with duplicates
save `initial_duplicates_using' // save tempfile with duplicates

* keep no duplicates in using
use `using_merge_unmatched'
duplicates tag `varlist' last_last initial, gen(dup) // tag duplciates
drop if dup > 0 // keep only unique observations
drop dup
save `using_merge_unmatched', replace

* tag duplicates in master
use `merge_first'
keep if _merge == 1 // keep just unmatched from master
drop _merge
drop `replace' // drop varlist of interest
tempfile master_merge_unmatched
save `master_merge_unmatched'

* save dataset with extra duplicates
duplicates tag `varlist' last_last initial, gen(dup)
tab dup
drop if dup == 0
drop dup
tempfile initial_duplicates_master
save `initial_duplicates_master'

* get master dataset without duplicates
use `master_merge_unmatched'
duplicates tag `varlist' last_last initial, gen(dup)
drop if dup != 0
drop dup
save `master_merge_unmatched', replace


* First Pass: merge with last_last
************************************************************************

* merge fec data with the voteview data
merge 1:1 `varlist' last_last initial using `using_merge_unmatched' 
tempfile merge_initial
save `merge_initial'

* save matched results in dataset to keep for later
keep if _merge == 3
append using `merge_matched'
save `merge_matched', replace

* Second Pass: merge with last1
************************************************************************

* try again on first word of last name with unmatched results
use `merge_initial'
keep if _merge == 2 // keep just unmatched from using
drop _merge // drop merge variable
save `using_merge_unmatched', replace

* get master unmatched 
use `merge_initial'
keep if _merge == 1 // keep just unmatched from master
drop _merge
drop `replace' // drop varlist of interest
save `master_merge_unmatched', replace

* merge
merge 1:1 `varlist' last1 initial using `using_merge_unmatched'
tempfile merge_last1
save `merge_last1'

* append matches to prior matches
keep if _merge == 3 // keep just merges
append using `merge_matched'
save `merge_matched', replace

* Third Pass: merge with replaced nicknames
************************************************************************
di "nicknames"
* try again with remaining after replacing some nicknames
use `merge_last1' // use results from previous merge attempt
keep if _merge == 2 // keep using data

* replace initials for nicknames in using data
replace initial ="R" if first == "BOB" | first == "BOBBY" // Robert
replace initial = "R" if first == "DICK" // Richard
replace initial = "W" if first == "BILL" | first == "BILLY" | first == "BILLIE" // William
replace initial = "A" if first == "TONY" // Anthony
replace initial = "E" if first == "GENE" // Eugene
replace initial = "E" if first == "LIZ" | first == "LIZZIE" // Elizabeth
replace initial = "M" if first == "PEGGY" | first == "PEG" // Margaret
replace initial = "A" if first == "RON" // Aaron
replace initial = "E" if first == "TED" // Edward (Theodore would been matched prior)

drop _merge // drop merge variable
save `using_merge_unmatched', replace // save over unmatched file with new unmatched

* fec data
use `merge_last1' // use results from previous merge
keep if _merge == 1 // keep fec data
drop _merge // drop merge variable
drop `replace' // drop varlist of interest

* replace initials for nicknames in fec data
replace initial ="R" if first == "BOB" | first == "BOBBY" // Robert
replace initial = "R" if first == "DICK" // Richard
replace initial = "W" if first == "BILL" | first == "BILLY" | first == "BILLIE" // William
replace initial = "A" if first == "TONY" // Anthony
replace initial = "E" if first == "GENE" // Eugene
di "Elizabeth"
replace initial = "E" if first == "LIZ" | first == "LIZZIE" // Elizabeth
replace initial = "M" if first == "PEGGY" | first == "PEG" // Margaret
replace initial = "A" if first == "RON" // Aaron
replace initial = "E" if first == "TED" // Edward (Theodore would been matched prior)

save `master_merge_unmatched', replace // save over unmatched file with new unmatched

*** get rid of new duplicates
* tag duplicates in using
use  `using_merge_unmatched'
duplicates tag `varlist' last_last initial, gen(dup)
drop if dup == 0 // keep only duplicates
drop dup
tempfile nickname_duplicates_using // create tempfile with duplicates
save `nickname_duplicates_using' // save tempfile with duplicates

* keep no duplicates in using
use `using_merge_unmatched'
duplicates tag `varlist' last_last initial, gen(dup) // tag duplciates
drop if dup > 0 // keep only unique observations
drop dup
save `using_merge_unmatched', replace

* tag duplicates in master
use `master_merge_unmatched'
* save dataset with extra duplicates
duplicates tag `varlist' last_last initial, gen(dup)
tab dup
drop if dup == 0
drop dup
tempfile nickname_duplicates_master
save `nickname_duplicates_master'

* get master dataset without duplicates
use `master_merge_unmatched'
duplicates tag `varlist' last_last initial, gen(dup)
drop if dup != 0
drop dup
save `master_merge_unmatched', replace

* merge with new initials (using last_last)
merge 1:1 `varlist' last_last initial using `using_merge_unmatched'

tempfile merge_nicknames
save `merge_nicknames'

* append matches to prior matches
keep if _merge == 3
append using `merge_matched'
save `merge_matched', replace

* Fourth Pass: deal with hypenated last names (first hyphen)
***********************************************************************
* get just dwnom data
use `merge_nicknames' // use results from the last pass
keep if _merge == 2 // keep using
drop _merge
save `using_merge_unmatched', replace

* get duplicates with hypenated last name
duplicates tag `varlist' hyphen_last initial, gen(hyphen_last_dup)
keep if hyphen_last_dup > 0
drop hyphen_last_dup
tempfile using_hyphen_last_dups
save`using_hyphen_last_dups'

* remove duplicates with hyphenated lastname
use `using_merge_unmatched'
duplicates tag `varlist' hyphen_last initial, gen(hyphen_last_dup)
keep if hyphen_last_dup == 0
drop hyphen_last_dup
save`using_merge_unmatched', replace

use `merge_nicknames'
keep if _merge == 1
drop _merge 
drop `replace' // drop varlist of interest
save `master_merge_unmatched', replace

* tag duplicates and save dataset with just duplicates (fec)
duplicates tag `varlist' hyphen_last initial, gen(hyphen_last_dup)
keep if hyphen_last_dup > 0
drop hyphen_last_dup
tempfile master_hyphen_last_dups
save`master_hyphen_last_dups'

use `master_merge_unmatched'
duplicates tag `varlist' hyphen_last initial, gen(hyphen_last_dup)
keep if hyphen_last_dup == 0
drop hyphen_last_dup

* merge with first hyphenated last name
merge 1:1 `varlist' hyphen_last initial using `using_merge_unmatched'
tempfile merge_hyphen_last
save `merge_hyphen_last'

* append matches to prior matches
keep if _merge == 3
append using `merge_matched'
save `merge_matched', replace

* Fifth Pass: deal with hyphenated last names (first hyphen)
*****************************************************************
* get just dwnom data
use `merge_hyphen_last' // use results from the last pass
keep if _merge == 2 // keep using (dwnom)
drop _merge
save `using_merge_unmatched', replace

duplicates tag `varlist' hyphen1 initial, gen(hyphen_first_dup)
keep if hyphen_first_dup > 0
drop hyphen_first_dup
tempfile using_hyphen_first_dups
save`using_hyphen_first_dups'

use `using_merge_unmatched'
duplicates tag `varlist' hyphen1 initial, gen(hyphen_first_dup)
keep if hyphen_first_dup == 0
drop hyphen_first_dup
save`using_merge_unmatched', replace

use `merge_hyphen_last'
keep if _merge == 1
drop _merge 
drop `replace' // drop varlist of interest
save `master_merge_unmatched', replace

* tag duplicates and save dataset with just duplicates (fec)
duplicates tag `varlist' hyphen1 initial, gen(hyphen_first_dup)
keep if hyphen_first_dup > 0
drop hyphen_first_dup
tempfile master_hyphen_first_dups
save`master_hyphen_first_dups'

use `master_merge_unmatched'
duplicates tag `varlist' hyphen1 initial, gen(hyphen_first_dup)
keep if hyphen_first_dup == 0
drop hyphen_first_dup

* merge with first hyphenated last name
merge 1:1 `varlist' hyphen1 initial using `using_merge_unmatched'
tempfile merge_hyphen_first
save `merge_hyphen_first'

keep if _merge == 3
append using `merge_matched'
save `merge_matched', replace


* Sixth Pass: merge with no first names or initial (just last)
************************************************************************

* get just dwnom data
use `merge_hyphen_first' // use results from the last pass
keep if _merge == 2 // keep using (dwnom)
drop _merge
save `using_merge_unmatched', replace

* tag duplicates and save dataset with just duplicates (dwnom)
duplicates tag `varlist' last, gen(last_dup)
keep if last_dup > 0
drop last_dup
tempfile using_justlast_dups
save `using_justlast_dups' // save duplicate dataset

* remove duplicates and save unique dwnom data
use `using_merge_unmatched'
duplicates tag `varlist' last, gen(last_dup)
keep if last_dup == 0
drop last_dup
save `using_merge_unmatched', replace

* get just master fec data
use `merge_hyphen_first'
keep if _merge == 1
drop _merge
drop `replace' // drop varlist of interest
save `master_merge_unmatched', replace

* tag duplicates and save dataset with just duplicates (fec)
duplicates tag `varlist' last, gen(last_dup)
keep if last_dup > 0
drop last_dup
tempfile master_justlast_dups
tab last
save `master_justlast_dups'

* remove duplicates
use `master_merge_unmatched'
duplicates tag `varlist' last, gen(last_dup)
keep if last_dup == 0
drop last_dup

* merge with just last name
merge 1:1 `varlist' last using `using_merge_unmatched'
tempfile merge_justlast
save `merge_justlast'

* append matches to prior matches
keep if _merge == 3
append using `merge_matched'
save `merge_matched', replace

* Seventh Pass: fuzzy match on last name (exact on initial and everything else)
*******************************************************************************
* get just using data
use `merge_justlast'
keep if _merge == 2 // get using data
drop _merge  // drop _merge
generate idusing = _n // generate a using id
rename last last_using // rename last so it's not lost or replaced in merge
save `using_merge_unmatched', replace // save

* get just master data
use `merge_justlast'
keep if _merge == 1 // get just master dataset
drop _merge  // drop merge 
drop `replace' // drop replace
generate idmaster = _n // generate a master id
rename last last_master // rename last so it's not lost or replaced in merge
save `master_merge_unmatched', replace // save

* joinby to get all combinations of varlist
joinby `varlist' initial using `using_merge_unmatched'

* get string distance btw last names from last_using and last_master
ustrdist last_using last_master, gen(last_dist)

* keep if string distance is low enough that it could be a typo
keep if last_dist < 4

* sort last_distance so lowest distances are first
sort `varlist' last_master initial last_dist

* keep greatest first in group
by `varlist' last_master initial: keep if _n == 1

* save tempfile
tempfile fuzzy_joined
save `fuzzy_joined'
drop idusing idmaster last_using last_master last_dist // drop all the variables
gen _merge = 3
* append merge matched and save
append using `merge_matched'
save `merge_matched', replace

* get using unmatched
use `using_merge_unmatched'
merge 1:1 idusing using `fuzzy_joined', keepusing(last_master)
keep if _merge == 1
drop idusing _merge last_master
rename last_using last
save `using_merge_unmatched', replace 

* get master_unmatched
use `master_merge_unmatched'
merge 1:1 idmaster using `fuzzy_joined', keepusing(last_using) // merge on id_master
keep if _merge == 1 // keep unmatched in master only
drop idmaster _merge last_using // drop created variables
rename last_master last // rename back to the appropriate variable
save `master_merge_unmatched', replace


* Eigth Pass: try without variable
***************************************************************
local newvarlist : list varlist - trywithout
di "`newvarlist'"

/*
* get just using data
use `merge_justlast'
keep if _merge == 2 // get using (dwnom) data
drop _merge 
save `using_merge_unmatched', replace
*/
use `using_merge_unmatched'

duplicates tag `newvarlist' last_last initial, gen(trywithout_dups_using)
keep if trywithout_dups_using > 0
drop trywithout_dups_using

tempfile using_trywithout_dups
save `using_trywithout_dups'

use `using_merge_unmatched'

duplicates tag `newvarlist' last_last initial, gen(trywithout_dups_using)
keep if trywithout_dups_using == 0
drop trywithout_dups_using

save `using_merge_unmatched', replace

use `master_merge_unmatched'
/*
use `merge_justlast'
keep if _merge == 1 // get just master dataset
drop _merge 
*/
capture drop `replace'
save `master_merge_unmatched', replace

duplicates tag `newvarlist' last_last initial, gen(trywithout_dups_using)
keep if trywithout_dups_using > 0
drop trywithout_dups_using

tempfile master_trywithout_dups
save `master_trywithout_dups'

use `master_merge_unmatched'
duplicates tag `newvarlist' last_last initial, gen(trywithout_dups_using)
keep if trywithout_dups_using == 0
drop trywithout_dups_using

* merge without party
merge 1:1 `newvarlist' last_last initial using `using_merge_unmatched'
tempfile merge_trywithout
save `merge_trywithout'

* append matches to prior matches
keep if _merge == 3
append using `merge_matched'
save `merge_matched', replace

 
* Ninth Pass: deal with the duplicates dropped previously
***********************************************************************

* get just using data
use `merge_trywithout'
keep if _merge == 2 // get using data
drop _merge

* append using duplicates
append using `using_justlast_dups'
append using `using_hyphen_first_dups'
append using `using_hyphen_last_dups'
append using `initial_duplicates_using'
append using `using_trywithout_dups'
append using `first_duplicates_using'
append using `nickname_duplicates_using'


duplicates tag `varlist' last first, gen(dupdup)
* save dwnom dups tempfile for merge
save `using_merge_unmatched', replace
keep if dupdup > 0  // keep if no dups for last merge
drop dupdup
gen _merge = 2
tempfile using_dupdup
save `using_dupdup' // save remaining dups for appending at the end
use `using_merge_unmatched' // now get back the non duplicated dataset
keep if dupdup == 0
drop dupdup
save `using_merge_unmatched', replace


* get unmatched fec data
use `merge_trywithout', clear
keep if _merge == 1
capture drop _merge
capture drop `replace' // drop varlist of interest
save `master_merge_unmatched', replace

* append fec duplicates together
append using `initial_duplicates_master'
append using `master_justlast_dups'
append using `master_hyphen_first_dups'
append using `master_hyphen_last_dups'
append using `master_trywithout_dups'
append using `first_duplicates_master'
append using `nickname_duplicates_master'

duplicates tag `varlist' last first, gen(dupdup)
* save dwnom dups tempfile for merge
save `master_merge_unmatched', replace

keep if dupdup > 0  // keep if no dups for last merge
drop dupdup
gen _merge = 1
tempfile master_dupdup
save `master_dupdup' // save remaining dups for appending at the end
use `master_merge_unmatched' // now get back the non duplicated dataset
keep if dupdup == 0
drop dupdup
save `master_merge_unmatched', replace
* merge with unmatched dw_nom data
merge 1:1 `varlist' last first using `using_merge_unmatched'


* append matched data
append using `merge_matched'
append using `using_dupdup'
append using `master_dupdup'

tab _merge

end
	
