/***
_version 1.3_ 

megamerge
===== 

__megamerge__ performs up to 16 merges sequentially to exhaustively link data with names and additional variables. 

Syntax
------ 

> __megamerge__ _varlist_ using _filename_ [, _options_]

| _options_          |  _Description_          |
|:-------------------------------|:-------------------------------------------------------------|
| __trywithout(_var_)__          | try merge without included variable                          |
| __messy__                      | keep intermediate variables created by megamerge             |
| __omitmerges(_merge_codes_)__  | do not perform the merges corresponding to the listed codes  |
| __keepmerges(_merge_codes_)__  | perform only the merges corresponding to the listed codes    |


Description
-----------

__megamerge__ performs sequential 1:1 merges in decreasing orders of specificity to match record with names. __megamerge__ requires that both master and using data have the variables first, last, middle, and suffix.

Each merge is in decreasing levels of specificity, so observations are matched on the most information avaiable. Since the merges are 1:1, observations that are not unique merge variables in the master and the using are omitted at each merge but appended to the ummatched data for the next merge. 

Options
-------

__trywithout(_var_)__ runs one iteration of the merge without the specificed variable. The variable given the this option must be contained in the varlist given originally to megamerge. 

__messy__ specifies that all variables created by megamerge (and all from using not of interest) be kept. By default, megamerge keeps the variables originally in master and using.

__keepmerges(_mergecodes_)__ specifies that only merges corresponding to _merge_codes_ be run. This option supercedes omitmerges().

__omitmerges(_mergecode_)__ specifies that merges corresponding to the _merge_codes_ (detailed below) be skipped.


Merge Codes
-----------

| **merge code** | **explanation**                                                           |
|----------------|---------------------------------------------------------------------------|
| 0              | merge vars + first + last + middle + suffix                               |
| 1              | merge vars + first + last + suffix                                        |
| 2              | merge vars + first + last + middle                                        |
| 3              | merge vars + first + last + middle initial                                |
| 4              | merge vars + first + last                                                 |
| 5              | merge vars + last word of last name + first                               |
| 6              | merge vars + first word of last name + first                              |
| 7              | merge vars + last + initial                                               |
| 8              | merge vars + last + first names standardized for common nicknames         |
| 9              | merge vars + last + first part of hyphenated last name + first initial    |
| 10             | merge vars + second part of hyphenated last name + first initial          |
| 11             | merge vars + last name without any spaces or hyphens                      |
| 12             | merge vars + middle appended to last name (no spaces), middlelast         |
| 13             | merge vars + last name appended to middle (no spaces), lastmiddle         |
| 14             | merge vars + last                                                         |
| 15             | merge vars except for var specified in trywithout option + last + first   |
| 100            | unmatched observations from master data                                   |
| 101            | omitted duplicate observations from master data (unmatched)               |
| 200            | unmatched observations from using data                                    |
| 201            | omitted duplicate observations from using data (unmatched)                |

Process
-------

Each phase of megamerge consists of the following steps
1. Specify list of variables to be used in the merge
2. Append previously omitted duplicates from master and using to unmatched observations from master and using respectively.
3. Generate new variables for certain merges
4. Save and separte duplicate obsevations from master and using in a separate dataset.
5. Perform a 1:1 merge of master to using on the variable list for that merge
6. Append matched observations with a merge_code to indicate which merge a match came from to prior matched observations.
7. Separate out observations that were not matched from master and using for use in the next merge.

Remarks
-------

The "m:1" and "1:m" merge options allow for duplicate observations, however, observations are only grouped together as duplicates if they match on last, first, middle, suffix, and all provided merge variables. Observations that would be considered duplicates for later stage merges (say, on first, last, and merge variables) but differ on other relevant variables (say different middles) would not be considered separate observations from the perspective of megamerge.



Example(s)
----------

    performs a megamerge of data in memory to data2 on name vars, state, and dist to get pop

        . megamerge state dist using data2

    performs same megamerge, but tries a round without the district variable

        . megamerge state dist using data2, trywithout(dist)
		
    performs same megamerge, but only on last name and on last and initial

        . megamerge state dist using data2, trywithout(dist) keepmerges(7 14)
		
    performs same megamerge, but without a merge on nicknames

        . megamerge state dist using data2, trywithout(dist) omitmerge(8)
		
	performs same megamerge, but keeps all intermediate variables

        . megamerge state dist using data2, trywithout(dist) messy

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
syntax varlist using/ [, trywithout(string) messy omitmerges(string) keepmerges(string)]

* arguments: master using varlist
** master = master dataset
** using = using dataset
** varlist = varlist for merge 

******************************************
* Get list of included merges
******************************************

* set list to keepmerges contents if specified
if "`keepmerges'" != ""{
	numlist "`keepmerges'"
	local included_merges `r(numlist)'
}
* if no keepmerges, omit omitmerges contents if sepcified
else if "`omitmerges'" != ""{
	numlist "0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15"
	local my_list `r(numlist)'
	local included_merges : list my_list - omitmerges
}
* if neither option is specified, do all merges
else{
	numlist "0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15"
	local included_merges `r(numlist)'
}

*****************************
* Preclean Master
*****************************

* drop initial variables
check_drop merge_code merge matched initial last1 last2 last3 last4 last_last hyphen hyphen1 hyphen2 hyphen3 hyphen_parts, dataset(using)


* get list of variables originally present in master
describe, varlist
local mastervars = "`r(varlist)'"

di "`mastervars'"

* make all name info uppercase
* make upper case
foreach var of varlist first middle last suffix {
	replace `var' = upper(`var')
	replace `var' = subinstr(`var', ".", "", .)
	replace `var' = subinstr(`var', `"""', "", .)
	replace `var' = subinstr(`var', "(", "",.)
	replace `var' = subinstr(`var', ")", "",.)
}

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

/* FOR FUTURE USE
* handle m:1 option
* if m:1 merge
if "`mergetype'" == "m:1"{
	* generate group variable id on full varlist for merges
	egen megamerge_master_id = group(`varlist' last first middle suffix), missing autotype
	bys megamerge_master_id: gen obs_duplicate = 1 if _n != 1
	* save off full unmatched list
	tempfile master_m1_dups
	save `master_m1_dups'
	* subset to just one observation for each combination of merge vars
	bys megamerge_master_id: keep if _n == 1
	* save
	tempfile master_merge_unmatched
	save `master_merge_unmatched'
}
else{
	* save the using data for a 1:1 or a 1:m merge
	gen megamerge_master_id = .
	tempfile master_merge_unmatched
	save `master_merge_unmatched'
}
*/

* save master file
tempfile master_merge_unmatched
save `master_merge_unmatched'


**********************************
* Preclean Using
**********************************

use `using', clear

// List of variables to check
check_drop merge_code merge matched initial last1 last2 last3 last4 last_last hyphen hyphen1 hyphen2 hyphen3 hyphen_parts, dataset(using)

* get list of variables originally present in master
describe, varlist
local usingvars = "`r(varlist)'" 

* make all variables uppercase and drop periods
foreach var of varlist first middle last suffix {
	replace `var' = upper(`var')
	replace `var' = subinstr(`var', ".", "", .)
	replace `var' = subinstr(`var', `"""', "", .)
	replace `var' = subinstr(`var', "(", "",.)
	replace `var' = subinstr(`var', ")", "",.)
}

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

/* FOR FUTURE USE
* handle 1:m option
* if m:1 merge
if "`mergetype'" == "1:m"{
	* generate group variable id on full varlist for merges
	egen megamerge_using_id = group(`varlist' last first middle suffix), missing autotype
	bys megamerge_using_id: gen obs_duplicate = 0 if _n != 1
	* save off full unmatched list
	tempfile using_1m_dups
	save `using_1m_dups'
	* subset to just one observation for each combination of merge vars
	bys megamerge_using_id: keep if _n == 1
	* save
	tempfile using_merge_unmatched
	save `using_merge_unmatched'
}
else{
	* save the using data for a 1:1 or a m:1 merge 
	gen megamerge_using_id = . 
	tempfile using_merge_unmatched
	save `using_merge_unmatched'
} */


* save the using data
tempfile using_merge_unmatched
save `using_merge_unmatched'

****************************************
* Make replace varlist
****************************************
local replace : list usingvars - mastervars

******************************
* Make requisite tempfiles
******************************
tempfile all_duplicates_using
tempfile all_duplicates_master
tempfile merge_matched
tempfile using_nodups

foreach i in `included_merges' {
	di `i'
	if `i' == 0 {
		local merge_varlist "last first middle suffix"
	}
	else if `i' == 1 {
		local merge_varlist "last first suffix"
	}
	else if `i' == 2 {
		local merge_varlist "last first middle"
	}
	else if `i' == 3 {
		local merge_varlist "first last middle_init"
	}
	else if `i' == 4 {
		local merge_varlist "last first "
	}
	else if `i' == 5 {
		local merge_varlist "last_last first"
	}
	else if `i' == 6 {
		local merge_varlist "last1 first"
	}
	else if `i' == 7 {
		local merge_varlist "last initial"
	}
	else if `i' == 8 {
		local merge_varlist "last fake_first"
	}
	else if `i' == 9 {
		local merge_varlist "hyphen_last initial"
	}
	else if `i' == 10 {
		local merge_varlist "hyphen1 initial"
	}
	else if `i' == 11 {
		local merge_varlist "nohyphen_last initial"
	}
	else if `i' == 12 {
		local merge_varlist "appended_middlelast"
	}
	else if `i' == 13 {
		local merge_varlist "appended_lastmiddle"
	}
	else if `i' == 14{
		local merge_varlist last
	}
	* perform merge step
	if `i' != 15{
		* perform merge step
		minimerge `varlist', extravars(`merge_varlist')  ///
		replace(`replace') merge_code(`i')  ///
		using_merge_unmatched(`using_merge_unmatched') ///
		master_merge_unmatched(`master_merge_unmatched') merge_matched(`merge_matched') ///
		all_duplicates_using(`all_duplicates_using') all_duplicates_master(`all_duplicates_master')
	}
	* handle trywithout option
	else if `i' == 15{
		if "`trywithout'" != "" {
			foreach item in `trywithout'{
				local tempvarlist : list varlist - item // get og varlist minus trywithout var
				minimerge `tempvarlist', extravars(last first) replace(`replace') /// 
					merge_code(`i') using_merge_unmatched(`using_merge_unmatched')  ///
					master_merge_unmatched(`master_merge_unmatched')  ///
					merge_matched(`merge_matched') all_duplicates_using(`all_duplicates_using') ///
					all_duplicates_master(`all_duplicates_master') 
			}
		}
	}
	
}

*************************************************
* Append remaining datasets
*************************************************
* generate merge_code for using unmatched
use `using_merge_unmatched'
capture gen merge_code = 200
save `using_merge_unmatched', replace

* generate merge_code for master unmatched
use `master_merge_unmatched'
capture gen merge_code = 100
save `master_merge_unmatched', replace

* generate merge_code for using duplicates
use `all_duplicates_using'
capture gen merge_code = 201
save `all_duplicates_using', replace

* generate merge_code for master duplicates
use `all_duplicates_master'
capture gen merge_code = 101
save `all_duplicates_master', replace

append using `using_merge_unmatched'
append using `master_merge_unmatched'
append using `all_duplicates_using'
append using `merge_matched'

********************************************************************************
* Handle special merges - for future use
********************************************************************************
/*
* many to one merge back to duplicated results
if "`mergetype'" == "m:1"{
	preserve 
	keep if megamerge_master_id == .
	tempfile no_m1_master_id
	save `no_m1_master_id'
	restore
	keep `usingvars' megamerge_master_id merge_code obs_duplicate // keep relevant vars
	drop if megamerge_master_id == .
	merge 1:m megamerge_master_id using `master_m1_dups'
	* check to make sure there are no unmatched observations in using
	drop _merge
	duplicates report megamerge_master_id
	append using `no_m1_master_id'
}
* one to many merge back to duplicated results
if "`mergetype'" == "1:m"{
	preserve 
	keep if megamerge_using_id == .
	tempfile no_1m_using_id
	save `no_1m_using_id'
	restore
	keep `master_vars' megamerge_using_id merge_code obs_duplicate // keep relevant vars
	drop if megamerge_using_id == .
	merge 1:m megamerge_using_id using `using_1m_dups'
	* check to make sure there are no unmatched obs in master
	drop _merge
	duplicates report megamerge_using_id
	append using `no_1m_using_id'
}
*/
***********************************************
* Clean up code for messy option
***********************************************
* keep variables in master and variables of interest from using
if "`messy'" == ""{
	local keep_vars : list mastervars | usingvars
	keep `keep_vars' merge_code
}

***********************************************
* Label merge_code
***********************************************

gen matched = 1 if merge_code < 200 & merge_code >= 100
replace matched = 2 if merge_code >= 200  
replace matched = 3 if merge_code < 20

label define merge_labs  0 "0: all" /// 
						 1 "1: all - middle" ///
						 2 "2: all - suffix" ///
						 3 "3: vars + middle_init + first + last" ///
						 4 "4: vars + first + last" ///
						 5 "5: vars + lastlast + first" ///
						 6 "6: vars + firstlast + first" ///
						 7 "7: vars + last + initial" ///
						 8 "8: vars + last + nickname" ///
						 9 "9: vars + hyphen2 + initial" ///
						 10 "10: vars + hypen1 + initial" ///
						 11 "11: vars + last smooshed" ///
						 12 "12: vars + middlelast" ///
						 13 "13: vars + lastmiddle" ///
						 14 "14: vars + last" ///
						 15 "15: vars - trywithout" ///
						 200 "200: unmatched from using" ///
						 201 "201: omitted duplicate from using" ///
						 100 "100: unmatched from master" ///
						 101 "101: omitted duplicate from master"
label values merge_code merge_labs

label define match_code  1 "Not matched from master" ///
					     2 "Not matched from using" ///
					     3 "Matched"
label values matched match_code		

order `mastervars' `replace' merge_code matched 

tab merge_code
tab matched





end
	

