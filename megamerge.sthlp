{smcl}
{it:version 1.1} 


{title:megamerge}

{p 4 4 2}
{bf:megamerge} performs 15 1:1 merges sequentially to exhaustively link data with names and additional variables. 


{title:Syntax}

{p 8 8 2} {bf:megamerge} {it:varlist} using {it:filename} , replace({it:varlist}) [ {it:options}]

{col 5}{it:option}{col 30}{it:Description}
{space 4}{hline 72}
{col 5}replace({it:varlist}){col 30}retains variables of interest from using data
{col 5}trywithout({it:var}){col 30}try merge without included variable
{space 4}{hline 72}


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


{title:Merge Codes}

{col 5}{ul:merge code}{col 21}{ul:explanation}
{space 4}{hline}
{col 5}0{col 21}merge vars \+ first \+ last \+ middle\+ suffix
{col 5}1{col 21}merge vars \+ first \+ last \+ suffix
{col 5}2{col 21}merge vars \+ first \+ last \+ middle
{col 5}3{col 21}merge vars \+ first \+ last \+ middle initial
{col 5}4{col 21}merge vars \+ first \+ last
{col 5}5{col 21}merge vars \+ last word of last name \+ first
{col 5}6{col 21}merge vars \+ first word of last name \+ first
{col 5}7{col 21}merge vars \+ last \+ initial
{col 5}8{col 21}merge vars \+ last \+ first names standardized for common nicknames
{col 5}9{col 21}merge vars \+ last \+ second part of hyphen \+ first initial
{col 5}10{col 21}merge vars \+ first part of hyphen \+ first initial
{col 5}11{col 21}merge vars \+ last name without any spaces or hyphens
{col 5}12{col 21}merge vars \+ middle appended to last name \(no spaces\), middlelast
{col 5}13{col 21}merge vars \+ ast name appended to middle\(no spaces\), lastmiddle
{col 5}14{col 21}merge vars \+ last
{col 5}15{col 21}merge vars except for var specified in trywithout option \+ last \+ first
{col 5}100{col 21}unmatched observations from master data
{col 5}101{col 21}omitted duplicate observations from master data (unmatched)
{col 5}200{col 21}unmatched observations from using data
{col 5}201{col 21}omitted duplicate observations from using data (unmatched).
{space 4}{hline}

{title:Remarks}

{p 4 4 2}
Stuff about how megamerge works


{title:Example(s)}

    performs a megamerge of data in memory to data2 on name vars, state, and dist to get pop

        . megamerge state dist using data2, replace(pop)

    performs same megamerge, but tries a round without the district variable

        . megamerge state dist using data2, replace(pop) trywithout(dist)


{title:Stored results}

{p 4 4 2}
describe the Scalars, Matrices, Macros, stored by {bf:XXX}, for example:

{p 4 4 2}{bf:Scalars}

{p 8 8 2} {bf:r(level)}: explain what the scalar does 

{p 4 4 2}{bf:Matrices}

{p 8 8 2} {bf:r(table)}: explain what it includes

{p 4 4 2}
Functions


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


