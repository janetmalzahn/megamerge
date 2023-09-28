capture program drop minimerge
program define minimerge

* define version number
version 15.1

* define the syntax
syntax varlist, extravars(string) [replace(string)] merge_code(int) using_merge_unmatched(string) master_merge_unmatched(string) merge_matched(string) all_duplicates_master(string) all_duplicates_using(string)

*------------------------------------------
* make merge_varlist
*------------------------------------------

local merge_varlist `varlist' `extravars'

di "`merge_varlist'"

*-----------------------------------------
* separate out duplicates for the using
*-----------------------------------------
use `using_merge_unmatched'
* add previous duplicates dropped because they might be useful
capture append using `all_duplicates_using'
capture drop dup // drop dup previously generated

* check if zero observations left in using
if _N == 0{
	di "no using"
	clear
	exit, clear
}

if strpos("`extravars'", "nohyphen_last") > 0{
	di "nohyphen"
	* make hyphenless last
	gen nohyphen_last = subinstr(last,"-","",.)
	replace nohyphen_last = subinstr(nohyphen_last," ","",.)
}

if strpos("`extravars'", "fake_first") > 0{
	di "nickname"
	replace_nicknames
}


if strpos("`extravars'", "appended_middlelast") > 0{
	* make appended last of last + middle
	capture gen nohyphen_last = subinstr(last,"-","",.)
	capture replace nohyphen_last = subinstr(nohyphen_last," ","",.)
	gen appended_middlelast = cond(length(middle)>2,middle + nohyphen_last,nohyphen_last)
}

if strpos("`extravars'", "appended_lastmiddle") > 0{
	* make appended last of middle + last
	capture gen nohyphen_last = subinstr(last,"-","",.)
	capture replace nohyphen_last = subinstr(nohyphen_last," ","",.)
	gen appended_lastmiddle = cond(length(middle)>2,nohyphen_last+middle,nohyphen_last)
}

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
capture append using `all_duplicates_master'
capture drop dup // drop dup previously generated

if _N == 0{
	di "no master"
	exit, clear
}

if strpos("`extravars'", "nohyphen_last") > 0{
	di "nohyphen"
	* make hyphenless last
	gen nohyphen_last = subinstr(last,"-","",.)
	replace nohyphen_last = subinstr(nohyphen_last," ","",.)
}

if strpos("`extravars'", "fake_first") > 0{
	di "nickname"
	replace_nicknames
}


if strpos("`extravars'", "appended_middlelast") > 0{
	* make appended last of last + middle
	capture gen nohyphen_last = subinstr(last,"-","",.)
	capture replace nohyphen_last = subinstr(nohyphen_last," ","",.)
	gen appended_middlelast = cond(length(middle)>2,middle + nohyphen_last,nohyphen_last)
}

if strpos("`extravars'", "appended_lastmiddle") > 0{
	* make appended last of middle + last
	capture gen nohyphen_last = subinstr(last,"-","",.)
	capture replace nohyphen_last = subinstr(nohyphen_last," ","",.)
	gen appended_lastmiddle = cond(length(middle)>2,nohyphen_last+middle,nohyphen_last)
}

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
	capture gen merge_code = `merge_code'
	capture append using `merge_matched'
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
	
end
