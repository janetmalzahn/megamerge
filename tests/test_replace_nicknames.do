/*******************************************************************************
* test_replace_nicknames.do
* Unit tests for replace_nicknames.ado
*
* Run from project root:
*   run tests/test_replace_nicknames.do
*   run_replace_nicknames_tests
*******************************************************************************/

* Load dependencies
run tests/test_helpers.do
run replace_nicknames.ado

capture program drop run_replace_nicknames_tests
program define run_replace_nicknames_tests

    di as text _n "============================================"
    di as text "RUNNING TESTS: replace_nicknames.ado"
    di as text "============================================"

    *--------------------------------------------------------------------------
    * Test 1: Robert nicknames
    *--------------------------------------------------------------------------
    test_begin "robert_variants"

    clear
    set obs 9
    gen str20 first = ""
    replace first = "ROB" in 1
    replace first = "BOB" in 2
    replace first = "BOBBY" in 3
    replace first = "ROBBIE" in 4
    replace first = "ROBBY" in 5
    replace first = "BOBBIE" in 6
    replace first = "ROBERTA" in 7
    replace first = "BERT" in 8
    replace first = "ROBERT" in 9

    qui replace_nicknames

    count if fake_first == "ROBERT"
    local all_robert = (r(N) == 9)
    test_assert `all_robert' "All_Robert_variants_should_map_to_ROBERT"

    test_pass

    *--------------------------------------------------------------------------
    * Test 2: William nicknames
    *--------------------------------------------------------------------------
    test_begin "william_variants"

    clear
    set obs 6
    gen str20 first = ""
    replace first = "WILL" in 1
    replace first = "WILLIE" in 2
    replace first = "BILL" in 3
    replace first = "BILLIE" in 4
    replace first = "LIAM" in 5
    replace first = "WILLIAM" in 6

    qui replace_nicknames

    count if fake_first == "WILLIAM"
    local all_william = (r(N) == 6)
    test_assert `all_william' "All_William_variants_should_map_to_WILLIAM"

    test_pass

    *--------------------------------------------------------------------------
    * Test 3: Elizabeth nicknames
    *--------------------------------------------------------------------------
    test_begin "elizabeth_variants"

    clear
    set obs 6
    gen str20 first = ""
    replace first = "LIZ" in 1
    replace first = "LIZZIE" in 2
    replace first = "ELIZA" in 3
    replace first = "BETH" in 4
    replace first = "LIZZY" in 5
    replace first = "ELIZABETH" in 6

    qui replace_nicknames

    count if fake_first == "ELIZABETH"
    local all_elizabeth = (r(N) == 6)
    test_assert `all_elizabeth' "All_Elizabeth_variants_should_map_to_ELIZABETH"

    test_pass

    *--------------------------------------------------------------------------
    * Test 4: Margaret nicknames
    *--------------------------------------------------------------------------
    test_begin "margaret_variants"

    clear
    set obs 9
    gen str20 first = ""
    replace first = "PEG" in 1
    replace first = "PEGGY" in 2
    replace first = "MAGGIE" in 3
    replace first = "MEG" in 4
    replace first = "MEGAN" in 5
    replace first = "MARGE" in 6
    replace first = "MARGIE" in 7
    replace first = "MEAGHAN" in 8
    replace first = "MARGARET" in 9

    qui replace_nicknames

    count if fake_first == "MARGARET"
    local all_margaret = (r(N) == 9)
    test_assert `all_margaret' "All_Margaret_variants_should_map_to_MARGARET"

    test_pass

    *--------------------------------------------------------------------------
    * Test 5: Edward nicknames (maps to ED)
    *--------------------------------------------------------------------------
    test_begin "edward_variants"

    clear
    set obs 9
    gen str20 first = ""
    replace first = "EDWARD" in 1
    replace first = "EDDY" in 2
    replace first = "EDDIE" in 3
    replace first = "EDWIN" in 4
    replace first = "EDMUND" in 5
    replace first = "TED" in 6
    replace first = "TEDDY" in 7
    replace first = "THEODORE" in 8
    replace first = "THEO" in 9

    qui replace_nicknames

    count if fake_first == "ED"
    local all_ed = (r(N) == 9)
    test_assert `all_ed' "All_Edward_variants_should_map_to_ED"

    test_pass

    *--------------------------------------------------------------------------
    * Test 6: Names that should NOT change
    *--------------------------------------------------------------------------
    test_begin "unchanged_names"

    clear
    set obs 6
    gen str20 first = ""
    replace first = "SARAH" in 1
    replace first = "OLIVIA" in 2
    replace first = "NOAH" in 3
    replace first = "EMMA" in 4
    replace first = "AIDEN" in 5
    replace first = "SOPHIA" in 6

    qui replace_nicknames

    count if fake_first == first
    local unchanged = (r(N) == 6)
    test_assert `unchanged' "Names_without_mappings_should_stay_unchanged"

    test_pass

    *--------------------------------------------------------------------------
    * Test 7: James nicknames
    *--------------------------------------------------------------------------
    test_begin "james_variants"

    clear
    set obs 6
    gen str20 first = ""
    replace first = "JIM" in 1
    replace first = "JIMMY" in 2
    replace first = "JIMBO" in 3
    replace first = "JIMMIE" in 4
    replace first = "JIMI" in 5
    replace first = "JAMES" in 6

    qui replace_nicknames

    count if fake_first == "JAMES"
    local all_james = (r(N) == 6)
    test_assert `all_james' "All_James_variants_should_map_to_JAMES"

    test_pass

    *--------------------------------------------------------------------------
    * Test 8: Michael nicknames
    *--------------------------------------------------------------------------
    test_begin "michael_variants"

    clear
    set obs 6
    gen str20 first = ""
    replace first = "MIKE" in 1
    replace first = "MICKEY" in 2
    replace first = "MIKEY" in 3
    replace first = "MICKY" in 4
    replace first = "MICK" in 5
    replace first = "MICHAEL" in 6

    qui replace_nicknames

    count if fake_first == "MICHAEL"
    local all_michael = (r(N) == 6)
    test_assert `all_michael' "All_Michael_variants_should_map_to_MICHAEL"

    test_pass

    *--------------------------------------------------------------------------
    * Test 9: Creates fake_first variable
    *--------------------------------------------------------------------------
    test_begin "creates_fake_first_variable"

    clear
    set obs 2
    gen str20 first = "JOHN"

    * Verify fake_first doesn't exist before
    capture confirm variable fake_first
    local no_fake_first_before = (_rc != 0)
    test_assert `no_fake_first_before' "fake_first_should_not_exist_before"

    qui replace_nicknames

    * Verify fake_first exists after
    capture confirm variable fake_first
    local fake_first_exists = (_rc == 0)
    test_assert `fake_first_exists' "fake_first_should_exist_after"

    test_pass

    *--------------------------------------------------------------------------
    * Summary
    *--------------------------------------------------------------------------
    di as text _n "============================================"
    di as text "REPLACE_NICKNAMES TESTS COMPLETE"
    if $any_test_failed {
        di as error "Some tests FAILED"
    }
    else {
        di as result "All tests PASSED"
    }
    di as text "============================================"

end

* To run: run_replace_nicknames_tests
