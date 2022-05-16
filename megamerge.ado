/***
_version 1.1_ 

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

replace(_varlist_) ensures that the variables the user wants to merge from the using to the master do not get replaced. For example, if the user wants to merge in "id" from using, they must use the replace(id) option. This option is required.

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

qui{
* arguments: master using varlist
** master = master dataset
** using = using dataset
** varlist = varlist for merge 

******************************************
* Make sure replace option is specified
******************************************
assert("`replace'" != "")

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
capture drop dup
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
capture drop dup
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
capture drop dup // drop dup previously generated

* tag duplicates in using
duplicates tag `merge_varlist', gen(dup)
preserve // get dataset with just duplicates
	keep if dup > 0 // separate out duplicates
	append using `all_duplicates_using'
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
capture drop dup // drop dup previously generated

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
capture drop dup // drop dup previously generated

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
capture drop dup // drop dup previously generated

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
capture drop dup // drop dup previously generated

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
capture drop dup // drop dup previously generated

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
* Sixth Pass: merge with last and initial
******************************************************

local merge_varlist `varlist' initial last

*-----------------------------------------
* separate out duplicates for the using
*-----------------------------------------
use `using_merge_unmatched'
* add previous duplicates dropped because they might be useful
append using `all_duplicates_using'
capture drop dup // drop dup previously generated

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
capture drop dup // drop dup previously generated

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
* Seventh Pass: merge with last and nicknames (initial)
******************************************************

local merge_varlist `varlist' last fake_first

use `using_merge_unmatched'

*------------------------------------------
* add nicknames
*------------------------------------------
gen fake_first = first
* replace initials for nicknames in using data
replace fake_first = "ROBERT" if inlist(first, "ROB", "BOB", "BOBBY", "ROBBIE", "ROBBY", "BOBBIE") // Robert
replace fake_first = "RICHARD" if inlist(first, "DICK", "RICHIE", "RICH", "RICHY", "RICK") // Richard
replace fake_first = "WILLIAM" if inlist(first, "WILL", "WILLIE", "BILL", "BILLIE", "LIAM")
replace fake_first = "ANTHONY" if inlist(first, "TONY", "ANTON", "ANT") // Anthony
replace fake_first = "EUGENE" if first == "GENE" // Eugene
replace fake_first = "ELIZABETH" if inlist(first, "LIZ", "LIZZIE", "ELIZA", "BETH", "LIZZY") // Elizabeth
replace fake_first = "MARGARET" if inlist(first, "PEG", "PEGGY", "MAGGIE", "MEG", "MEGAN") // Margaret
replace fake_first = "AARON" if first == "RON" // Aaron
replace fake_first = "EDWARD" if inlist(first, "ED", "EDDY", "EDDIE", "EDWIN", "EDMUND", "TED", "TEDDY","THEODORE", "THEO") // Edward 
replace fake_first = "ALEX" if inlist(first, "ZANDER", "ALEXANDER", "LEX") // Alex
replace fake_first = "JOSEPH" if inlist(first, "JOE", "JOEY", "JO", "JOSIAH") // Joseph
replace fake_first = "JOSHUA" if inlist(first, "JOSH", "JOSHIE") // Joshua
replace fake_first = "ELEANOR" if inlist(first, "ELANOR", "ELLE", "ELLIE", "NORA") //Eleanor
replace fake_first = "ABIGAIL" if inlist(first, "ABBY", "ABBIE", "GAIL") // Abigail
replace fake_first = "ANN" if inlist(first, "ANNA", "ANNE", "ANNABELL", "ANABELL", "ANABEL", "ANABELLE", "BELL", "BELLE") // Ann
replace fake_first = "REBECCA" if inlist(first, "REBECKA", "BECKY", "BEX", "REBEKAH") // Rebecca
replace fake_first = "BENJAMIN" if inlist(first, "BEN", "BENNIE", "BENJI") // Ben
replace fake_first = "CHARLES" if inlist(first, "CHARLIE", "CHARLEY", "CHUCK", "CHAS") // Charles
replace fake_first = "DANIEL" if inlist(first, "DANNY", "DAN") // Daniel
replace fake_first = "DAVID" if inlist(first, "DAVE", "DAVEY", "DAVIE") // David
replace fake_first = "JOHN" if inlist(first, "JON", "JOHNNY", "JONATHAN", "JOHNNIE")
replace fake_first = "CHRIS" if inlist(first, "CHRISTY", "CHRISSY", "TINA", "CHRISTINA", "CHRISTOPHER", "CHRISTOPH", "CRIS", "KRIS") // Chris
replace fake_first = "KATHERINE" if inlist(first, "CATHERINE", "KATHERINE", "CATIE", "KATH", "KATIE") // Katherine
replace fake_first = "MICHAEL" if inlist(first, "MIKE", "MICKEY", "MIKEY", "MICKY", "MICK")
replace fake_first = "NATHAN" if inlist(first, "NATHANIEL", "NAT", "NATALIE", "NATTIE")
replace fake_first = "NICK" if inlist(first, "NICOLAS", "NIC", "NICKO", "NIKKO", "NICHOLAS")
replace fake_first = "EZEKIEL" if inlist(first, "ZEKE", "EZEKIAL")

*-----------------------------------------
* separate out duplicates for the using
*-----------------------------------------
* add previous duplicates dropped because they might be useful
append using `all_duplicates_using'
capture drop dup // drop dup previously generated

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
gen fake_first = first
* replace initials for nicknames in using data
replace fake_first = "ROBERT" if inlist(first, "ROB", "BOB", "BOBBY", "ROBBIE", "ROBBY", "BOBBIE") // Robert
replace fake_first = "RICHARD" if inlist(first, "DICK", "RICHIE", "RICH", "RICHY", "RICK") // Richard
replace fake_first = "WILLIAM" if inlist(first, "WILL", "WILLIE", "BILL", "BILLIE", "LIAM")
replace fake_first = "ANTHONY" if inlist(first, "TONY", "ANTON", "ANT") // Anthony
replace fake_first = "EUGENE" if first == "GENE" // Eugene
replace fake_first = "ELIZABETH" if inlist(first, "LIZ", "LIZZIE", "ELIZA", "BETH", "LIZZY") // Elizabeth
replace fake_first = "MARGARET" if inlist(first, "PEG", "PEGGY", "MAGGIE", "MEG", "MEGAN") // Margaret
replace fake_first = "AARON" if first == "RON" // Aaron
replace fake_first = "EDWARD" if inlist(first, "ED", "EDDY", "EDDIE", "EDWIN", "EDMUND", "TED", "TEDDY","THEODORE", "THEO") // Edward 
replace fake_first = "ALEX" if inlist(first, "ZANDER", "ALEXANDER", "LEX") // Alex
replace fake_first = "JOSEPH" if inlist(first, "JOE", "JOEY", "JO", "JOSIAH") // Joseph
replace fake_first = "JOSHUA" if inlist(first, "JOSH", "JOSHIE") // Joshua
replace fake_first = "ELEANOR" if inlist(first, "ELANOR", "ELLE", "ELLIE", "NORA") //Eleanor
replace fake_first = "ABIGAIL" if inlist(first, "ABBY", "ABBIE", "GAIL") // Abigail
replace fake_first = "ANN" if inlist(first, "ANNA", "ANNE", "ANNABELL", "ANABELL", "ANABEL", "ANABELLE", "BELL", "BELLE") // Ann
replace fake_first = "REBECCA" if inlist(first, "REBECKA", "BECKY", "BEX", "REBEKAH") // Rebecca
replace fake_first = "BENJAMIN" if inlist(first, "BEN", "BENNIE", "BENJI") // Ben
replace fake_first = "CHARLES" if inlist(first, "CHARLIE", "CHARLEY", "CHUCK", "CHAS") // Charles
replace fake_first = "DANIEL" if inlist(first, "DANNY", "DAN") // Daniel
replace fake_first = "DAVID" if inlist(first, "DAVE", "DAVEY", "DAVIE") // David
replace fake_first = "JOHN" if inlist(first, "JON", "JOHNNY", "JONATHAN", "JOHNNIE")
replace fake_first = "CHRIS" if inlist(first, "CHRISTY", "CHRISSY", "TINA", "CHRISTINA", "CHRISTOPHER", "CHRISTOPH", "CRIS", "KRIS") // Chris
replace fake_first = "KATHERINE" if inlist(first, "CATHERINE", "KATHERINE", "CATIE", "KATH", "KATIE") // Katherine
replace fake_first = "MICHAEL" if inlist(first, "MIKE", "MICKEY", "MIKEY", "MICKY", "MICK")
replace fake_first = "NATHAN" if inlist(first, "NATHANIEL", "NAT", "NATALIE", "NATTIE")
replace fake_first = "NICK" if inlist(first, "NICOLAS", "NIC", "NICKO", "NIKKO", "NICHOLAS")
replace fake_first = "EZEKIEL" if inlist(first, "ZEKE", "EZEKIAL")

*-----------------------------------------
* separate out duplicates for the master
*-----------------------------------------
* add previous duplicates dropped because they might be useful
append using `all_duplicates_master'
capture drop dup // drop dup previously generated

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
* Eight Pass: merge with hyphen_last + initial
******************************************************

local merge_varlist `varlist' hyphen_last initial

*-----------------------------------------
* separate out duplicates for the using
*-----------------------------------------
use `using_merge_unmatched'
* add previous duplicates dropped because they might be useful
append using `all_duplicates_using'
capture drop dup // drop dup previously generated

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
capture drop dup // drop dup previously generated

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
	capture gen merge_code = 8
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
* Ninth Pass: merge with hyphen_first + initial
******************************************************

local merge_varlist `varlist' hyphen1 initial

*-----------------------------------------
* separate out duplicates for the using
*-----------------------------------------
use `using_merge_unmatched'
* add previous duplicates dropped because they might be useful
append using `all_duplicates_using'
capture drop dup // drop dup previously generated

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
capture drop dup // drop dup previously generated

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
	gen merge_code = 9
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
* Tenth Pass: merge with just last
******************************************************

local merge_varlist `varlist' last

*-----------------------------------------
* separate out duplicates for the using
*-----------------------------------------
use `using_merge_unmatched'
* add previous duplicates dropped because they might be useful
append using `all_duplicates_using'
capture drop dup // drop dup previously generated

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
capture drop dup // drop dup previously generated

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
	capture gen merge_code = 10
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
	
/*
	
***************************************************************
* Eleventh Pass: fuzzy merge on last (with initial and all covs)
***************************************************************

local merge_varlist `varlist' first

*------------------------------------------
* prep using for the joinby
*------------------------------------------
* get just using data
use `using_merge_unmatched'
append using `all_duplicates_using'
capture drop dup // drop dup previously generated

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
capture drop dup // drop dup previously generated

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
capture gen merge_code = 11 // make a merge code
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
*/

******************************************************
* Twelth Pass: trywithout each variable
******************************************************
local merge_varlist `varlist' last

if "`trywithout'" != "" {
foreach item in `trywithout'{
	local tempvarlist : list varlist - item
	local merge_varlist `tempvarlist' last_last first
	
	*-----------------------------------------
	* separate out duplicates for the using
	*-----------------------------------------
	use `using_merge_unmatched'
	* add previous duplicates dropped because they might be useful
	append using `all_duplicates_using'
	capture drop dup // drop dup previously generated

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
	capture drop dup // drop dup previously generated

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
	save `merge_all', replace

	preserve
		* append matches to prior matches
		keep if _merge == 3
		capture gen merge_code = 12
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

label define merge_labs  0 "0: all" /// 
						 1 "1: all - middle" ///
						 2 "2: all - suffix" ///
						 3 "3: vars + middle_init + first + last" ///
						 4 "4: vars + lastlast + first" ///
						 5 "5: vars + firstlast + first" ///
						 6 "6: vars + last + initial" ///
						 7 "7: vars + last + nickname" ///
						 8 "8: vars + hyphen2 + initial" ///
						 9 "9: vars + hypen1 + initial" ///
						 10 "10: vars + last" ///
						 11 "11: vars + first + fuzzy last" ///
						 12 "12: vars - trywithout" ///
						 100 "100: unmatched from using" ///
						 101 "101: omitted duplicate from using" ///
						 200 "200: unmatched from master" ///
						 201 "201: omitted duplicate from master"
label values merge_code merge_labs

label define match_code  1 "Not matched from master" ///
					     2 "Not matched from using" ///
					     3 "Matched"
label values matched match_code

}					 

tab merge_code
tab matched


end
	



