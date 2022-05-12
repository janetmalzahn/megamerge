/***
_version 1.0_ 

megamerge
===== 

__megamerge__ performs 10 sequential merges to exhaustively link data with names and additional variables.

Syntax
------ 

> __megamerge__ _varlist_ using _filename_ , replace(_varlist_) [ _options_]

| _option_          |  _Description_          |
|:------------------------|:----------------------------------------------|
| replace(_varlist_)     | retains variables of interest from using data   |
| trywithout(_var_) | try merge without included variable  |


Description
-----------

megamerge performs sequential 1:1 merges in decreasing orders of specificity to match record with names. Megamerge requires that both master and using data have the variables first, last, middle, and suffix. 

Options
-------

replace(_varlist_) ensures that the variables you are trying to merge from the using to the master do not get replaced. For example, if the user wants to merge in "id" from using, they must use the replace(id) option.

trywithout(_var_) runs one iteration of the merge without the specificed variable. The variable given the this option must be contained in the varlist given originally to megamerge. 

Remarks
-------

Stuff about how megamerge works

Example(s)
----------

    performs a megamerge of data in memory to data2 on name vars, state, and dist to get pop

        . megamerge state dist using data2, replace(pop)

    performs same megamerge, but tries a round without the district variable

        . megamerge state dist using data2, replace(pop) trywithout(dist)

Stored results
--------------

describe the Scalars, Matrices, Macros, stored by __XXX__, for example:

### Scalars

> __r(level)__: explain what the scalar does 

### Matrices

> __r(table)__: explain what it includes

Functions

Author
------

Janet Malzahn  
Stanford Institute for Economic Policy Research    
jmalzahn@stanford.edu   

License
-------

Specify the license of the software

References
----------

Janet Malzahn (2022), [Megamerge](https://github.com/haghish/markdoc/)

- - -

This help file was dynamically produced by 
[MarkDoc Literate Programming package](http://www.haghish.com/markdoc/) 
***/


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

* gen middle initial
capture gen middle_init = substr(middle,1,1)


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

* gen middle initial
capture gen middle_init = substr(middle,1,1)

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

/*
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
*/

************************************************************************
* Zeroth Pass: merge with all information
************************************************************************

* make varlist for this merge 
local merge_varlist `varlist' last first middle suffix
*-----------------------------------------
* separate out duplicates for the using
*-----------------------------------------
use `using_data'
* tag initial duplicates in using
duplicates tag `merge_varlist', gen(dup)
preserve // get dataset with just duplicates
	keep if dup > 0 // separate out duplicates
	drop dup
	tempfile all_duplicates_using // save file
	save `all_duplicates_using'
restore

drop if dup != 0
drop dup
tempfile using_nodups
save `using_nodups' // save file without duplicates

*------------------------------------------
* separate out duplicates for the master
*------------------------------------------

* tag initial duplicates in master
use `master'
* tag initial duplicates in master
duplicates tag `merge_varlist', gen(dup)
preserve // get dataset with just duplicates
	keep if dup > 0 // separate out duplicates
	drop dup
	tempfile all_duplicates_master // save file
	save `all_duplicates_master'
restore

drop if dup != 0
drop dup

*------------------------------------------
* merge_all
*------------------------------------------
* merge with just last name
merge 1:1 `merge_varlist' using `using_nodups'

preserve
	* append matches to prior matches
	keep if _merge == 3
	capture gen merge_code = 0
	tempfile merge_matched
	save `merge_matched'
	
restore, preserve
	* append get unmatched from master
	keep if _merge == 2
	capture drop _merge
	tempfile using_merge_unmatched
	save `using_merge_unmatched'
restore
	keep if _merge == 1
	capture drop _merge 
	capture drop `replace'
	tempfile master_merge_unmatched
	save `master_merge_unmatched'

******************************************************
* First Pass: Merge Without Middle Name
******************************************************
* make varlist for this merge 
local merge_varlist `varlist' last first suffix

*-----------------------------------------
* separate out duplicates for the using
*-----------------------------------------
use `using_merge_unmatched'
append using `all_duplicates_using'
* tag initial duplicates in using
duplicates tag `merge_varlist', gen(dup)
preserve // get dataset with just duplicates
	keep if dup > 0 // separate out duplicates
	drop dup
	save `all_duplicates_using', replace
restore

drop if dup != 0
drop dup
save `using_nodups', replace // save file without duplicates

*------------------------------------------
* separate out duplicates for the master
*------------------------------------------

* tag initial duplicates in master
use `master_merge_unmatched'
append using `all_duplicates_master'
drop dup
* tag initial duplicates in master
duplicates tag `merge_varlist', gen(dup)
preserve // get dataset with just duplicates
	keep if dup > 0 // separate out duplicates
	save `all_duplicates_master', replace
restore

drop if dup != 0
drop dup

*------------------------------------------
* merge all variables but middle name
*------------------------------------------
* merge with all variables but middle name
merge 1:1 `merge_varlist' using `using_nodups'

tempfile merge_all
save `merge_all'

preserve
	* append matches to prior matches
	keep if _merge == 3
	capture gen merge_code = 1
	append using `merge_matched'
	save `merge_matched', replace
	
restore, preserve
	* save unmatched from using
	keep if _merge == 2
	capture drop _merge
	save `using_merge_unmatched', replace
	
restore
	* save unmatched from master
	keep if _merge == 1
	capture drop _merge
	capture drop `replace' // drop variable we want to replace
	save `master_merge_unmatched', replace
	
*********************************************************
* Second Pass: merge with all but suffix
*********************************************************
local merge_varlist `varlist' first last middle 

*-----------------------------------------
* separate out duplicates for the using
*-----------------------------------------
use `using_merge_unmatched'
* add previous duplicates dropped because they might be useful
append using `all_duplicates_using'
drop dup // drop dup previously generated

* tag duplicates in using
duplicates tag `merge_varlist', gen(dup)
preserve // get dataset with just duplicates
	keep if dup > 0 // separate out duplicates
	append using `all_duplicates_using'
	save `all_duplicates_using', replace
restore

drop if dup != 0
drop dup
tempfile using_nodups
save `using_nodups', replace // save file without duplicates

*------------------------------------------
* separate out duplicates for the master
*------------------------------------------

* tag initial duplicates in master
use `master_merge_unmatched'
* add previous duplicates dropped because they might be useful
append using `all_duplicates_master'
drop dup // drop dup previously generated

* tag initial duplicates in master
duplicates tag `merge_varlist', gen(dup)
preserve // get dataset with just duplicates
	keep if dup > 0 // separate out duplicates
	save `all_duplicates_master', replace
restore

drop if dup != 0
drop dup

*------------------------------------------
* merge all variables but middle name
*------------------------------------------
* merge with all variables but middle name
merge 1:1 `merge_varlist' using `using_nodups'

tempfile merge_all
save `merge_all'

preserve
	* append matches to prior matches
	keep if _merge == 3
	capture gen merge_code = 2
	append using `merge_matched'
	save `merge_matched', replace
	
restore, preserve
	* save unmatched from using
	keep if _merge == 2
	capture drop _merge
	save `using_merge_unmatched', replace
	
restore
	* save unmatched from master
	keep if _merge == 1
	capture drop _merge
	capture drop `replace'
	save `master_merge_unmatched', replace

****************************************************
* Third Pass: Merge on Middle Init + First + Last
****************************************************

local merge_varlist `varlist' first last middle_init

*-----------------------------------------
* separate out duplicates for the using
*-----------------------------------------
use `using_merge_unmatched'
* add previous duplicates dropped because they might be useful
append using `all_duplicates_using'
drop dup // drop dup previously generated

* tag duplicates in using
duplicates tag `merge_varlist', gen(dup)
preserve // get dataset with just duplicates
	keep if dup > 0 // separate out duplicates
	save `all_duplicates_using', replace
restore

drop if dup != 0
drop dup
tempfile using_nodups
save `using_nodups', replace // save file without duplicates

*------------------------------------------
* separate out duplicates for the master
*------------------------------------------

* tag initial duplicates in master
use `master_merge_unmatched'
* add previous duplicates dropped because they might be useful
append using `all_duplicates_master'
drop dup // drop dup previously generated

* tag initial duplicates in master
duplicates tag `merge_varlist', gen(dup)
preserve // get dataset with just duplicates
	keep if dup > 0 // separate out duplicates
	save `all_duplicates_master', replace
restore

drop if dup != 0
drop dup

*-----------------------------------------------
* merge variables + first + last + middle_init
*-----------------------------------------------
* merge with all variables but middle name
merge 1:1 `merge_varlist' using `using_nodups'

tempfile merge_all
save `merge_all'

preserve
	* append matches to prior matches
	keep if _merge == 3
	capture gen merge_code = 3
	append using `merge_matched'
	save `merge_matched', replace
	
restore, preserve
	* save unmatched from using
	keep if _merge == 2
	capture drop _merge
	save `using_merge_unmatched', replace
	
restore
	* save unmatched from master
	keep if _merge == 1
	capture drop _merge
	capture drop `replace'
	save `master_merge_unmatched', replace
	
******************************************************
* Fourth Pass: merge with last_last and first
******************************************************

local merge_varlist `varlist' first last_last

*-----------------------------------------
* separate out duplicates for the using
*-----------------------------------------
use `using_merge_unmatched'
* add previous duplicates dropped because they might be useful
append using `all_duplicates_using'
drop dup // drop dup previously generated

* tag duplicates in using
duplicates tag `merge_varlist', gen(dup)
preserve // get dataset with just duplicates
	keep if dup > 0 // separate out duplicates
	save `all_duplicates_using', replace
restore

drop if dup != 0
drop dup
save `using_nodups', replace // save file without duplicates

*------------------------------------------
* separate out duplicates for the master
*------------------------------------------

* tag initial duplicates in master
use `master_merge_unmatched'
* add previous duplicates dropped because they might be useful
append using `all_duplicates_master'
drop dup // drop dup previously generated

* tag initial duplicates in master
duplicates tag `merge_varlist', gen(dup)
preserve // get dataset with just duplicates
	keep if dup > 0 // separate out duplicates
	save `all_duplicates_master', replace
restore

drop if dup != 0
drop dup

*-----------------------------------------------
* merge variables + first + last + middle_init
*-----------------------------------------------
* merge with all variables but middle name
merge 1:1 `merge_varlist' using `using_nodups'

tempfile merge_all
save `merge_all'

preserve
	* append matches to prior matches
	keep if _merge == 3
	capture gen merge_code = 4
	append using `merge_matched'
	save `merge_matched', replace
	
restore, preserve
	* save unmatched from using
	keep if _merge == 2
	capture drop _merge
	save `using_merge_unmatched', replace
	
restore
	* save unmatched from master
	keep if _merge == 1
	capture drop _merge
	capture drop `replace'
	save `master_merge_unmatched', replace

******************************************************
* Fifth Pass: merge with last1 and first
******************************************************

local merge_varlist `varlist' first last1

*-----------------------------------------
* separate out duplicates for the using
*-----------------------------------------
use `using_merge_unmatched'
* add previous duplicates dropped because they might be useful
append using `all_duplicates_using'
drop dup // drop dup previously generated

* tag duplicates in using
duplicates tag `merge_varlist', gen(dup)
preserve // get dataset with just duplicates
	keep if dup > 0 // separate out duplicates
	save `all_duplicates_using', replace
restore

drop if dup != 0
drop dup
save `using_nodups', replace // save file without duplicates

*------------------------------------------
* separate out duplicates for the master
*------------------------------------------

* tag initial duplicates in master
use `master_merge_unmatched'
* add previous duplicates dropped because they might be useful
append using `all_duplicates_master'
drop dup // drop dup previously generated

* tag initial duplicates in master
duplicates tag `merge_varlist', gen(dup)
preserve // get dataset with just duplicates
	keep if dup > 0 // separate out duplicates
	save `all_duplicates_master', replace
restore

drop if dup != 0
drop dup

*-----------------------------------------------
* merge variables + first + last + middle_init
*-----------------------------------------------
* merge with all variables but middle name
merge 1:1 `merge_varlist' using `using_nodups'

tempfile merge_all
save `merge_all'

preserve
	* append matches to prior matches
	keep if _merge == 3
	capture gen merge_code = 5
	append using `merge_matched'
	save `merge_matched', replace
	
restore, preserve
	* save unmatched from using
	keep if _merge == 2
	capture drop _merge
	save `using_merge_unmatched', replace
	
restore
	* save unmatched from master
	keep if _merge == 1
	capture drop _merge
	capture drop `replace'
	save `master_merge_unmatched', replace
	
******************************************************
* Sixth Pass: merge with last and nicknames (initial)
******************************************************

local merge_varlist `varlist' last_last initial

use `using_merge_unmatched'

*------------------------------------------
* add nicknames
*------------------------------------------
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

*-----------------------------------------
* separate out duplicates for the using
*-----------------------------------------
* add previous duplicates dropped because they might be useful
append using `all_duplicates_using'
drop dup // drop dup previously generated

* tag duplicates in using
duplicates tag `merge_varlist', gen(dup)
preserve // get dataset with just duplicates
	keep if dup > 0 // separate out duplicates
	save `all_duplicates_using', replace
restore

drop if dup != 0
drop dup
save `using_nodups', replace // save file without duplicates

*------------------------------------------
* read in the master
*------------------------------------------

* tag initial duplicates in master
use `master_merge_unmatched'
*------------------------------------------
* add nicknames
*------------------------------------------
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

*-----------------------------------------
* separate out duplicates for the master
*-----------------------------------------
* add previous duplicates dropped because they might be useful
append using `all_duplicates_master'
drop dup // drop dup previously generated

* tag initial duplicates in master
duplicates tag `merge_varlist', gen(dup)
preserve // get dataset with just duplicates
	keep if dup > 0 // separate out duplicates
	save `all_duplicates_master', replace
restore

drop if dup != 0
drop dup

*-----------------------------------------------
* merge variables + first + last + middle_init
*-----------------------------------------------
* merge with all variables but middle name
merge 1:1 `merge_varlist' using `using_nodups'

tempfile merge_all
save `merge_all'

preserve
	* append matches to prior matches
	keep if _merge == 3
	capture gen merge_code = 6
	append using `merge_matched'
	save `merge_matched', replace
	
restore, preserve
	* save unmatched from using
	keep if _merge == 2
	capture drop _merge
	save `using_merge_unmatched', replace
	
restore
	* save unmatched from master
	keep if _merge == 1
	capture drop _merge
	capture drop `replace'
	save `master_merge_unmatched', replace
	
******************************************************
* Seventh Pass: merge with hyphen_last + initial
******************************************************

local merge_varlist `varlist' hyphen_last initial

*-----------------------------------------
* separate out duplicates for the using
*-----------------------------------------
use `using_merge_unmatched'
* add previous duplicates dropped because they might be useful
append using `all_duplicates_using'
drop dup // drop dup previously generated

* tag duplicates in using
duplicates tag `merge_varlist', gen(dup)
preserve // get dataset with just duplicates
	keep if dup > 0 // separate out duplicates
	save `all_duplicates_using', replace
restore

drop if dup != 0
drop dup
save `using_nodups', replace // save file without duplicates

*------------------------------------------
* separate out duplicates for the master
*------------------------------------------

* tag initial duplicates in master
use `master_merge_unmatched'
* add previous duplicates dropped because they might be useful
append using `all_duplicates_master'
drop dup // drop dup previously generated

* tag initial duplicates in master
duplicates tag `merge_varlist', gen(dup)
preserve // get dataset with just duplicates
	keep if dup > 0 // separate out duplicates
	save `all_duplicates_master', replace
restore

drop if dup != 0
drop dup

*-----------------------------------------------
* merge variables + first + last + middle_init
*-----------------------------------------------
* merge with all variables but middle name
merge 1:1 `merge_varlist' using `using_nodups'

tempfile merge_all
save `merge_all'

preserve
	* append matches to prior matches
	keep if _merge == 3
	capture gen merge_code = 7
	append using `merge_matched'
	save `merge_matched', replace
	
restore, preserve
	* save unmatched from using
	keep if _merge == 2
	capture drop _merge
	save `using_merge_unmatched', replace
	
restore
	* save unmatched from master
	keep if _merge == 1
	capture drop _merge
	capture drop `replace'
	save `master_merge_unmatched', replace
	
******************************************************
* Eight Pass: merge with hyphen_first + initial
******************************************************

local merge_varlist `varlist' hyphen1 initial

*-----------------------------------------
* separate out duplicates for the using
*-----------------------------------------
use `using_merge_unmatched'
* add previous duplicates dropped because they might be useful
append using `all_duplicates_using'
drop dup // drop dup previously generated

* tag duplicates in using
duplicates tag `merge_varlist', gen(dup)
preserve // get dataset with just duplicates
	keep if dup > 0 // separate out duplicates
	save `all_duplicates_using', replace
restore

drop if dup != 0
drop dup
save `using_nodups', replace // save file without duplicates

*------------------------------------------
* separate out duplicates for the master
*------------------------------------------

* tag initial duplicates in master
use `master_merge_unmatched'
* add previous duplicates dropped because they might be useful
append using `all_duplicates_master'
drop dup // drop dup previously generated

* tag initial duplicates in master
duplicates tag `merge_varlist', gen(dup)
preserve // get dataset with just duplicates
	keep if dup > 0 // separate out duplicates
	save `all_duplicates_master', replace
restore

drop if dup != 0
drop dup

*-----------------------------------------------
* merge variables + first + last + middle_init
*-----------------------------------------------
* merge with all variables but middle name
merge 1:1 `merge_varlist' using `using_nodups'

preserve
	* append matches to prior matches
	keep if _merge == 3
	gen merge_code = 8
	append using `merge_matched'
	save `merge_matched', replace
	
restore, preserve
	* save unmatched from using
	keep if _merge == 2
	capture drop _merge
	save `using_merge_unmatched', replace
	
restore
	* save unmatched from master
	keep if _merge == 1
	capture drop _merge
	capture drop `replace'
	save `master_merge_unmatched', replace

******************************************************
* Ninth Pass: merge with just last
******************************************************

local merge_varlist `varlist' last

*-----------------------------------------
* separate out duplicates for the using
*-----------------------------------------
use `using_merge_unmatched'
* add previous duplicates dropped because they might be useful
append using `all_duplicates_using'
drop dup // drop dup previously generated

* tag duplicates in using
duplicates tag `merge_varlist', gen(dup)
preserve // get dataset with just duplicates
	keep if dup > 0 // separate out duplicates
	save `all_duplicates_using', replace
restore

drop if dup != 0
drop dup
save `using_nodups', replace // save file without duplicates

*------------------------------------------
* separate out duplicates for the master
*------------------------------------------

* tag initial duplicates in master
use `master_merge_unmatched'
* add previous duplicates dropped because they might be useful
append using `all_duplicates_master'
drop dup // drop dup previously generated

* tag initial duplicates in master
duplicates tag `merge_varlist', gen(dup)
preserve // get dataset with just duplicates
	keep if dup > 0 // separate out duplicates
	save `all_duplicates_master', replace
restore

drop if dup != 0
drop dup

*-----------------------------------------------
* merge variables + last
*-----------------------------------------------
* merge with all variables but middle name
merge 1:1 `merge_varlist' using `using_nodups'

tempfile merge_all
save `merge_all'

preserve
	* append matches to prior matches
	keep if _merge == 3
	capture gen merge_code = 9
	append using `merge_matched'
	save `merge_matched', replace
	
restore, preserve
	* save unmatched from using
	keep if _merge == 2
	capture drop _merge
	save `using_merge_unmatched', replace
	
restore
	* save unmatched from master
	keep if _merge == 1
	capture drop _merge
	capture drop `replace'
	save `master_merge_unmatched', replace
	
***************************************************************
* Tenth Pass: fuzzy merge on last (with initial and all covs)
***************************************************************

local merge_varlist `varlist' initial

*------------------------------------------
* prep using for the joinby
*------------------------------------------
* get just using data
use `using_merge_unmatched'
append using `all_duplicates_using'
drop dup // drop dup previously generated

* tag duplicates in using
duplicates tag `merge_varlist' last, gen(dup)
preserve // get dataset with just duplicates
	keep if dup > 0 // separate out duplicates
	save `all_duplicates_using', replace
restore

drop if dup != 0
drop dup
generate idusing = _n // generate a using id
rename last last_using // rename last so it's not lost or replaced in merge
save `using_nodups', replace // save file without duplicates

*-------------------------------------------
* prep master for the joinby
*-------------------------------------------
* tag initial duplicates in master
use `master_merge_unmatched'
* add previous duplicates dropped because they might be useful
append using `all_duplicates_master'
drop dup // drop dup previously generated

* tag initial duplicates in master
duplicates tag `merge_varlist', gen(dup)
preserve // get dataset with just duplicates
	keep if dup > 0 // separate out duplicates
	save `all_duplicates_master', replace
restore

drop if dup != 0
drop dup
generate idmaster = _n // generate a master id
rename last last_master // rename last so it's not lost or replaced in merge

* save tempfile of master without duplicates
tempfile master_nodups
save `master_nodups' // save

*-------------------------------------------
* joinby varlist
*-------------------------------------------
* joinby to get all combinations of varlist
joinby `varlist' initial using `using_nodups'

* get string distance btw last names from last_using and last_master
ustrdist last_using last_master, gen(last_dist)

* keep if string distance is low enough that it could be a typo
keep if last_dist < 4

* sort last_distance so lowest distances are first
sort `varlist' last_master initial last_dist

* keep greatest first in group
by `varlist' last_master initial: keep if _n == 1

tempfile fuzzy_joined
save `fuzzy_joined'

*--------------------------------------------
* save files
*--------------------------------------------
drop idusing idmaster last_using last_master last_dist // drop all the variables
capture gen _merge = 3 // make merge variable
capture gen merge_code = 10 // make a merge code
* append merge matched and save
append using `merge_matched'
save `merge_matched', replace

* get using unmatched
use `using_nodups'
merge 1:1 idusing using `fuzzy_joined', keepusing(last_master)
keep if _merge == 1
capture drop idusing _merge last_master
capture rename last_using last
save `using_merge_unmatched', replace 

* get master_unmatched
use `master_nodups'
merge 1:1 idmaster using `fuzzy_joined', keepusing(last_using) // merge on id_master
keep if _merge == 1 // keep unmatched in master only
capture drop idmaster _merge last_using // drop created variables
capture rename last_master last // rename back to the appropriate variable
capture drop `replace'
save `master_merge_unmatched', replace

******************************************************
* Eleventh Pass: trywithout each variable
******************************************************
local merge_varlist `varlist' last

foreach item in `trywithout'{
	local tempvarlist : list varlist - item
	local merge_varlist `tempvarlist' last_last first
	
	*-----------------------------------------
	* separate out duplicates for the using
	*-----------------------------------------
	use `using_merge_unmatched'
	* add previous duplicates dropped because they might be useful
	append using `all_duplicates_using'
	drop dup // drop dup previously generated

	* tag duplicates in using
	duplicates tag `merge_varlist', gen(dup)
	preserve // get dataset with just duplicates
		keep if dup > 0 // separate out duplicates
		save `all_duplicates_using', replace
	restore

	drop if dup != 0
	drop dup
	save `using_nodups', replace // save file without duplicates

	*------------------------------------------
	* separate out duplicates for the master
	*------------------------------------------

	* tag initial duplicates in master
	use `master_merge_unmatched'
	* add previous duplicates dropped because they might be useful
	append using `all_duplicates_master'
	drop dup // drop dup previously generated

	* tag initial duplicates in master
	duplicates tag `merge_varlist', gen(dup)
	preserve // get dataset with just duplicates
		keep if dup > 0 // separate out duplicates
		save `all_duplicates_master', replace
	restore

	drop if dup != 0
	drop dup

	*-----------------------------------------------
	* merge variables + last - each trywithout
	*-----------------------------------------------
	* merge with all variables but middle name
	merge 1:1 `merge_varlist' using `using_nodups'

	tempfile merge_all
	save `merge_all'

	preserve
		* append matches to prior matches
		keep if _merge == 3
		capture gen merge_code = 11
		append using `merge_matched'
		save `merge_matched', replace
		
	restore, preserve
		* save unmatched from using
		keep if _merge == 2
		capture drop _merge
		save `using_merge_unmatched', replace
		
	restore
		* save unmatched from master
		keep if _merge == 1
		capture drop _merge
		capture drop `replace'
		save `master_merge_unmatched', replace
}

*************************************************
* Append remaining datasets
*************************************************
* generate merge_code for using unmatched
use `using_merge_unmatched'
capture gen merge_code = 100
save `using_merge_unmatched', replace

* generate merge_code for master unmatched
use `master_merge_unmatched'
capture gen merge_code = 200
save `master_merge_unmatched', replace

* generate merge_code for using duplicates
use `all_duplicates_using'
capture gen merge_code = 101
save `all_duplicates_using', replace

* generate merge_code for master duplicates
use `all_duplicates_master'
capture gen merge_code = 201
save `all_duplicates_master', replace

append using `using_merge_unmatched'
append using `master_merge_unmatched'
append using `all_duplicates_using'
append using `merge_matched'

***********************************************
* Label merge_code
***********************************************

gen matched = 1 if merge_code >= 200
replace matched = 2 if merge_code >= 100 & merge_code < 200
replace matched = 3 if merge_code < 20

tab merge_code
table matched



********************************************************************************

/*

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

* tag duplicates and save dataset with just duplicates
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
*append using `first_duplicates_using'
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
*append using `first_duplicates_master'
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
*/

end
	



