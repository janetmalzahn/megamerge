*version 1.1*

megamerge
=========

**megamerge** performs 15 1:1 merges sequentially to exhaustively link
data with names and additional variables.

Syntax
------

> **megamerge** *varlist* using *filename* , replace(*varlist*) \[
> *options*\]

  *option*             *Description*
  -------------------- -----------------------------------------------
  replace(*varlist*)   retains variables of interest from using data
  trywithout(*var*)    try merge without included variable

Description
-----------

megamerge performs sequential 1:1 merges in decreasing orders of
specificity to match record with names. Megamerge requires that both
master and using data have the variables first, last, middle, and
suffix.

Each merge is in decreasing levels of specificity, so observations are
matched on the most information avaiable. Since the merges are 1:1,
observations that are not unique merge variables in the master and the
using are omitted at each merge but appended &gt; to the ummatched data
for the next merge.

Options
-------

replace(*varlist*) requires the user to specify which variables they
want to merge in from the using dataset, ensuring that the variables the
user wants to merge from the using to the master do not get replaced.
For example, if the user wants to merge in &gt; "id" from using, they
must use the replace(id) option. This option is *required*.

trywithout(*var*) runs one iteration of the merge without the specificed
variable. The variable given the this option must be contained in the
varlist given originally to megamerge.

Merge Codes
-----------

  ------------------------------------------------------------------------
  **merge       **explanation**
  code**        
  ------------- ----------------------------------------------------------
  0             merge vars + first + last + middle+ suffix

  1             merge vars + first + last + suffix

  2             merge vars + first + last + middle

  3             merge vars + first + last + middle initial

  4             merge vars + first + last

  5             merge vars + last word of last name + first

  6             merge vars + first word of last name + first

  7             merge vars + last + initial

  8             merge vars + last + first names standardized for common
                nicknames

  9             merge vars + last + second part of hyphen + first initial

  10            merge vars + first part of hyphen + first initial

  11            merge vars + last name without any spaces or hyphens

  12            merge vars + middle appended to last name (no spaces),
                middlelast

  13            merge vars + last name appended to middle (no spaces),
                lastmiddle

  14            merge vars + last

  15            merge vars except for var specified in trywithout option +
                last + first

  100           unmatched observations from master data

  101           omitted duplicate observations from master data
                (unmatched)

  200           unmatched observations from using data

  201           omitted duplicate observations from using data (unmatched)
  ------------------------------------------------------------------------

Remarks
-------

Each phase of megamerge consists of the following steps 1. Specify list
of variables to be used in the merge 2. Append previously omitted
duplicates from master and using to unmatched observations from master
and using respectively. 3. Generate new variables for certain merges 4.
Save and separte duplicate obsevations from master and using in a
separate dataset. 5. Perform a 1:1 merge of master to using on the
variable list for that merge 6. Append matched observations with a
merge\_code to indicate which merge a match came from to prior matched
observations. 7. Separate out observations that were not matched from
master and using for use in the next merge.

Example(s)
----------

    performs a megamerge of data in memory to data2 on name vars, state, and dist to get pop

            . megamerge state dist using data2, replace(pop)

    performs same megamerge, but tries a round without the district variable

            . megamerge state dist using data2, replace(pop) trywithout(dist)

Author
------

Janet Malzahn\
Stanford Institute for Economic Policy Research\
jmalzahn@stanford.edu

License
-------

Specify the license of the software

References
----------

Janet Malzahn (2022), [Megamerge](https://github.com/haghish/markdoc/)

------------------------------------------------------------------------

This help file was dynamically produced by [MarkDoc Literate Programming
package](http://www.haghish.com/markdoc/)
