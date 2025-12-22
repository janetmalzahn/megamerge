/*******************************************************************************
* setup_test_data.do
* Run once from project root to create test .dta files
* Usage: do tests/setup_test_data.do
*******************************************************************************/

clear all

* Create master test data
clear
input str20 first str20 middle str30 last str10 suffix int state int district float value1
"JOHN"      "MICHAEL"   "SMITH"         ""      1   101   100.5
"JANE"      "ANN"       "DOE"           ""      1   102   200.0
"BOB"       "LEE"       "JOHNSON"       "JR"    2   201   150.0
"MARY"      ""          "WILLIAMS"      ""      2   202   175.0
"WILLIAM"   "J"         "JONES"         ""      3   301   125.0
"WILLIAM"   "J"         "JONES"         ""      3   301   126.0
"ELIZABETH" "MARIE"     "CLARK LEWIS"   ""      4   401   250.0
"MARGARET"  ""          "WILSON-MILLER" ""      4   402   225.0
"ED"        "R"         "TAYLOR"        ""      5   501   180.0
"MICHAEL"   "JAMES"     "ANDERSON"      ""      5   502   190.0
"CHARLES"   "HENRY"     "BAKER"         "JR"    6   601   210.0
"THOMAS"    "EDWARD"    "CLARK"         ""      6   602   220.0
"DAVID"     "ALLEN"     "MOORE"         ""      7   701   230.0
"DAVID"     "BRIAN"     "MOORE"         ""      7   701   235.0
"UNMATCHED" "PERSON"    "MASTER"        ""      8   801   999.0
end
save tests/data/master_test.dta, replace

* Create using test data
clear
input str20 first str20 middle str30 last str10 suffix int state int district float value2
"JOHN"      "MICHAEL"   "SMITH"         ""      1   101   500.0
"JANE"      "A"         "DOE"           ""      1   102   600.0
"ROBERT"    "LEE"       "JOHNSON"       "JR"    2   201   550.0
"MARY"      ""          "WILLIAMS"      ""      2   202   575.0
"PETER"     "Q"         "PARKER"        ""      3   303   525.0
"PETER"     "Q"         "PARKER"        ""      3   303   526.0
"ELIZABETH" "MARIE"     "LEWIS"         ""      4   401   650.0
"MARGARET"  ""          "WILSON"        ""      4   402   625.0
"EDWARD"    "R"         "TAYLOR"        ""      5   501   580.0
"MICHAEL"   "J"         "ANDERSON"      ""      5   502   590.0
"CHARLES"   "HENRY"     "BAKER"         ""      6   601   610.0
"TIMOTHY"   "JAMES"     "CLARK"         ""      6   602   620.0
"DAVID"     "CHRIS"     "MOORE"         ""      7   701   630.0
"UNMATCHED" "PERSON"    "USING"         ""      9   901   888.0
end
save tests/data/using_test.dta, replace

* Create simple test data for unit tests
clear
input str20 first str20 middle str20 last str10 suffix int id
"JOHN"   "A"  "SMITH"   ""    1
"JANE"   "B"  "DOE"     ""    2
"BOB"    ""   "JONES"   ""    3
end
save tests/data/simple_master.dta, replace

clear
input str20 first str20 middle str20 last str10 suffix int id float score
"JOHN"   "A"  "SMITH"   ""    1   100.0
"JANE"   "B"  "DOE"     ""    2   200.0
"ROBERT" ""   "JONES"   ""    3   300.0
end
save tests/data/simple_using.dta, replace

* Create duplicate test data
clear
input str20 first str20 middle str20 last str10 suffix int state int id
"JOHN"   "A"  "SMITH"   ""    1   1
"JOHN"   "B"  "SMITH"   ""    1   2
"JOHN"   "C"  "SMITH"   ""    1   3
"JANE"   "D"  "DOE"     ""    2   4
end
save tests/data/duplicate_master.dta, replace

clear
input str20 first str20 middle str20 last str10 suffix int state float score
"JOHN"   "X"  "SMITH"   ""    1   100.0
"JOHN"   "Y"  "SMITH"   ""    1   200.0
"JANE"   "D"  "DOE"     ""    2   300.0
end
save tests/data/duplicate_using.dta, replace

* Create test data for name variation merges (nohyphen, appended)
* Tests cases where names are recorded differently but should still match

clear
input str20 first str20 middle str30 last str10 suffix int state int id
"MARY"    ""        "SMITH-JONES"    ""    1   1
"SARAH"   ""        "VAN DER BERG"   ""    2   2
"ANNA"    "MARIE"   "JOHNSON"        ""    3   3
"LISA"    "BETH"    "WILSON"         ""    4   4
"KATE"    ""        "BROWN"          ""    5   5
"NANCY"   "SUE"     "DAVIS"          ""    6   6
end
save tests/data/namevar_master.dta, replace

* Using: names recorded differently but matching via special merges
* MARY: hyphen removed -> nohyphen_last match
* SARAH: spaces removed -> nohyphen_last match
* ANNA: middle got absorbed into hyphenated last -> appended_middlelast match
* LISA: middle appended after last with hyphen -> appended_lastmiddle match
* KATE & NANCY: should NOT match (negative test cases)
clear
input str20 first str20 middle str30 last str10 suffix int state float score
"MARY"    ""        "SMITH JONES"     ""    1   100.0
"SARAH"   ""        "VANDERBERG"      ""    2   200.0
"ANNA"    ""        "MARIE-JOHNSON"   ""    3   300.0
"LISA"    ""        "WILSON-BETH"     ""    4   400.0
"KATE"    ""        "TOTALLY-DIFFERENT" ""  5   500.0
"NANCY"   ""        "WRONG-NAME"      ""    6   600.0
end
save tests/data/namevar_using.dta, replace

di as result "Test data files created in tests/data/"
