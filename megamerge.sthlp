{smcl}
{it:version 1.2} 


{title:megamerge}

{p 4 4 2}
{bf:megamerge} performs 15 1:1 merges sequentially to exhaustively link data with names and additional variables. 


{title:Syntax}

{p 8 8 2} {bf:megamerge} {it:varlist} using {it:filename} , replace({it:varlist}) [ {it:options}]

{col 5}{it:option}{col 31}{it:Description}
{space 4}{hline}
{col 5}replace({it:varlist}){col 31}retains variables of interest from using data
{col 5}trywithout({it:var}){col 31}try merge without included variable
{col 5}messy{col 31}keep intermediate variables created by megamerge
{col 5}omitmerges(integer list){col 31}do not perform the merges corresponding to the listed codes
{col 5}keepmerges(integer list){col 31}perform only the merges corresponding to the listed codes
{space 4}{hline}


{title:Description}

{p 4 4 2}
megamerge performs sequential 1:1 merges in decreasing orders of specificity to match record with names. Megamerge requires that both master and using data have the variables first, last, middle, and suffix.

{p 4 4 2}
Each merge is in decreasing levels of specificity, so observations are matched on the most information avaiable. Since the merges are 1:1, observations that are not unique merge variables in the master and the using are omitted at each merge but appended to the ummatched data for the next merge. 


{title:Options}

{p 4 4 2}
replace({it:varlist}) requires the user to specify which variables they want to merge in from the using dataset, ensuring that the variables the user wants to merge from the using to the master do not get replaced. For example, if the user wants to merge in "id" from using, they must use the replace(id) option. This option is {it:required}.

{p 4 4 2}
trywithout({it:var}) runs one iteration of the merge without the specificed variable. The variable given the this option must be contained in the varlist given originally to megamerge. 

{p 4 4 2}
messy keeps all variables created by megamerge (and all from using not of interest). By default, megamerge keeps the variables originally in master and those specified to the required replace() option.

{p 4 4 2}
keepmerges({it:integer list}) runs megamerge only the merges corresponding to the merge_codes (detailed below) specified in the option. This option supercedes omitmerges().

{p 4 4 2}
omitmerges({it:integer list}) runs megamerge without the merges corresponding to the merge_codes (detailed below) specified in the option.



{title:Merge Codes}

{col 5}{ul:merge code}{col 21}{ul:explanation}
{space 4}{hline}
{col 5}0{col 21}merge vars + first + last + middle + suffix
{col 5}1{col 21}merge vars + first + last + suffix
{col 5}2{col 21}merge vars + first + last + middle
{col 5}3{col 21}merge vars + first + last + middle initial
{col 5}4{col 21}merge vars + first + last
{col 5}5{col 21}merge vars + last word of last name + first
{col 5}6{col 21}merge vars + first word of last name + first
{col 5}7{col 21}merge vars + last + initial
{col 5}8{col 21}merge vars + last + first names standardized for common nicknames
{col 5}9{col 21}merge vars + last + first part of hyphenated last name + first initial
{col 5}10{col 21}merge vars + second part of hyphenated last name + first initial
{col 5}11{col 21}merge vars + last name without any spaces or hyphens
{col 5}12{col 21}merge vars + middle appended to last name (no spaces), middlelast
{col 5}13{col 21}merge vars + last name appended to middle (no spaces), lastmiddle
{col 5}14{col 21}merge vars + last
{col 5}15{col 21}merge vars except for var specified in trywithout option + last + first
{col 5}100{col 21}unmatched observations from master data
{col 5}101{col 21}omitted duplicate observations from master data (unmatched)
{col 5}200{col 21}unmatched observations from using data
{col 5}201{col 21}omitted duplicate observations from using data (unmatched)
{space 4}{hline}

{title:Remarks}

{p 4 4 2}
Each phase of megamerge consists of the following steps
{break}    1. Specify list of variables to be used in the merge
{break}    2. Append previously omitted duplicates from master and using to unmatched observations from master and using respectively.
{break}    3. Generate new variables for certain merges
{break}    4. Save and separte duplicate obsevations from master and using in a separate dataset.
{break}    5. Perform a 1:1 merge of master to using on the variable list for that merge
{break}    6. Append matched observations with a merge_code to indicate which merge a match came from to prior matched observations.
{break}    7. Separate out observations that were not matched from master and using for use in the next merge.


{title:Example(s)}

    performs a megamerge of data in memory to data2 on name vars, state, and dist to get pop

        . megamerge state dist using data2, replace(pop)

    performs same megamerge, but tries a round without the district variable

        . megamerge state dist using data2, replace(pop) trywithout(dist)


{title:Author}

{p 4 4 2}
Janet Malzahn    {break}
Stanford Institute for Economic Policy Research      {break}
jmalzahn@stanford.edu     {break}


{title:License}

{p 4 4 2}
Specify the license of the software


{title:References}

{p 4 4 2}
Janet Malzahn (2022),  {browse "https://github.com/haghish/markdoc/":Megamerge}

{space 4}{hline}

{p 4 4 2}
This help file was dynamically produced by 
{browse "http://www.haghish.com/markdoc/":MarkDoc Literate Programming package} 


