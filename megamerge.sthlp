{smcl}
{it:version 1.0} 


{title:megamerge}

{p 4 4 2}
{bf:megamerge} performs 10 sequential merges to exhaustively link data with names and additional variables.


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


{title:Options}

{p 4 4 2}
replace({it:varlist}) ensures that the variables you are trying to merge from the using to the master do not get replaced. For example, if the user wants to merge in "id" from using, they must use the replace(id) option.

{p 4 4 2}
trywithout({it:var}) runs one iteration of the merge without the specificed variable. The variable given the this option must be contained in the varlist given originally to megamerge. 


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


