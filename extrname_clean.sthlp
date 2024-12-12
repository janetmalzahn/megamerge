{smcl}
{* *! version 1.3}{...}
{viewerjumpto "Syntax" "extrname_clean##syntax"}{...}
{viewerjumpto "Description" "extrname_clean##description"}{...}
{viewerjumpto "Remarks" "extrname_clean##remarks"}{...}
{viewerjumpto "Examples" "extrname_clean##examples"}{...}
{title:extrname_clean}

{phang}
{bf:extrname_clean} - Clean up two-letter names and common last name prefixes

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:extrname_clean} {it:varlist} [{cmd:,} {it:options}]

{marker description}{...}
{title:Description}

{pstd}
{cmd:extrname_clean} wraps the extrname package to clean up two-letter names and common last name prefixes that are often first names (Mac, Von, and Van).

{pstd}
Similar to the original extrname command, the only input you need is the full name variable.

{marker remarks}{...}
{title:Remarks}

{pstd}
{cmd:extrname_clean} replaces any variables that the original {cmd:extrname} command must generate, including {bf:first}, {bf:middle}, {bf:last}, {bf:prefix}, {bf:suffix}, {bf:affil}, and {bf:odd}.

{pstd}
If you want to keep these variables, you should rename them before use. Otherwise, it makes the following changes that may or may not be desirable depending on your use case:

{phang2}- {bf:First names of Von, Van, or Mac:} These are kept as first names. Von, Van, or Mac is considered a first name if:{p_end}
{phang3}* They come after the comma in a "Last, First Middle" formatted name{p_end}
{phang3}* They are the first part of a "First Last" formatted name{p_end}
{phang3}* If a name contains just the last name (e.g., "Von Trap"), Von is considered a first name{p_end}

{phang2}- {bf:Two-letter names:} Names like Ed, Mo, Jo, etc., are considered first names{p_end}
{phang3}* The base {cmd:extrname} package considers Ed to be E. D., with E. as the first name and D. as the middle name{p_end}
{phang3}* If periods are present, the behavior defaults to the base {cmd:extrname} logic{p_end}

{phang2}- {bf:Capitalization:} All name components are capitalized{p_end}

{marker examples}{...}
{title:Examples}

{phang2}{cmd:. extrname_clean firstname lastname}{p_end}
{phang2}{cmd:. extrname_clean name, option1}{p_end}

{title:Author}

{pstd}Janet Malzahn{break}
Stanford Institute for Economic Policy Research{break}
jmalzahn@stanford.edu

{title:License}

{pstd}MIT

{title:References}

{pstd}Janet Malzahn (2022), {browse "https://github.com/haghish/markdoc":Megamerge}

{hline}
{pstd}This help file was dynamically produced by the {browse "http://www.haghish.com/markdoc/":MarkDoc Literate Programming package}.
{hline}