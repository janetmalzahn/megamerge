/*******************************************************************************
* test_minimerge.do
* Unit tests for minimerge.ado
*
* Uses test data from tests/data/ (run setup_test_data.do first)
*
* Run from project root:
*   run tests/test_minimerge.do
*   run_minimerge_tests
*******************************************************************************/

* Load dependencies
run tests/test_helpers.do
run replace_nicknames.ado
run minimerge.ado

capture program drop run_minimerge_tests
program define run_minimerge_tests

    di as text _n "============================================"
    di as text "RUNNING TESTS: minimerge.ado"
    di as text "============================================"

    * Check if test data exists
    capture confirm file "tests/data/simple_master.dta"
    if _rc != 0 {
        di as error "Test data not found. Run: do tests/setup_test_data.do"
        exit
    }

    *--------------------------------------------------------------------------
    * Test 1: Basic merge separates matched and unmatched
    *--------------------------------------------------------------------------
    test_begin "basic_merge_separation"

    * Load and prep master
    use tests/data/simple_master.dta, clear
    tempfile master_unmatched
    save `master_unmatched'

    * Load and prep using
    use tests/data/simple_using.dta, clear
    tempfile using_unmatched
    save `using_unmatched'

    * Create empty tempfiles with structure from using data
    keep in 1
    drop if _n > 0
    tempfile all_dups_master
    save `all_dups_master', replace
    tempfile all_dups_using
    save `all_dups_using', replace
    tempfile matched
    save `matched', replace

    * Run minimerge
    qui minimerge id, extravars(last first) replace(score) merge_code(0) ///
        using_merge_unmatched(`using_unmatched') ///
        master_merge_unmatched(`master_unmatched') ///
        merge_matched(`matched') ///
        all_duplicates_master(`all_dups_master') ///
        all_duplicates_using(`all_dups_using')

    * Check matched observations (JOHN and JANE should match exactly)
    use `matched', clear
    local matched_count = _N
    local has_matches = (`matched_count' == 2)
    test_assert `has_matches' "Should_have_2_matched_observations"

    * Check merge_code was set
    count if merge_code == 0
    local correct_code = (r(N) == 2)
    test_assert `correct_code' "Matched_should_have_merge_code_0"

    test_pass

    *--------------------------------------------------------------------------
    * Test 2: Duplicates are separated correctly
    *--------------------------------------------------------------------------
    test_begin "duplicate_separation"

    * Load duplicate test data
    use tests/data/duplicate_master.dta, clear
    tempfile master_unmatched
    save `master_unmatched'

    use tests/data/duplicate_using.dta, clear
    tempfile using_unmatched
    save `using_unmatched'

    * Create empty tempfiles
    keep in 1
    drop if _n > 0
    tempfile all_dups_master
    save `all_dups_master', replace
    tempfile all_dups_using
    save `all_dups_using', replace
    tempfile matched
    save `matched', replace

    * Run minimerge on state + last + first (JOHNs are duplicates)
    qui minimerge state, extravars(last first) replace(score) merge_code(0) ///
        using_merge_unmatched(`using_unmatched') ///
        master_merge_unmatched(`master_unmatched') ///
        merge_matched(`matched') ///
        all_duplicates_master(`all_dups_master') ///
        all_duplicates_using(`all_dups_using')

    * Check that master duplicates were separated (3 JOHNs)
    use `all_dups_master', clear
    count if first == "JOHN"
    local john_dups = r(N)
    local has_master_dups = (`john_dups' == 3)
    test_assert `has_master_dups' "3_JOHN_records_should_be_master_duplicates"

    * Check that using duplicates were separated (2 JOHNs)
    use `all_dups_using', clear
    count if first == "JOHN"
    local john_using_dups = r(N)
    local has_using_dups = (`john_using_dups' == 2)
    test_assert `has_using_dups' "2_JOHN_records_should_be_using_duplicates"

    * JANE should have matched (unique in both)
    use `matched', clear
    count if first == "JANE"
    local jane_matched = (r(N) == 1)
    test_assert `jane_matched' "JANE_should_match"

    test_pass

    *--------------------------------------------------------------------------
    * Test 3: fake_first (nickname) variable generation
    *--------------------------------------------------------------------------
    test_begin "fake_first_generation"

    * Use simple data - BOB in master, ROBERT in using
    use tests/data/simple_master.dta, clear
    keep if first == "BOB"
    tempfile master_unmatched
    save `master_unmatched'

    use tests/data/simple_using.dta, clear
    keep if first == "ROBERT"
    tempfile using_unmatched
    save `using_unmatched'

    * Create empty tempfiles
    keep in 1
    drop if _n > 0
    tempfile all_dups_master
    save `all_dups_master', replace
    tempfile all_dups_using
    save `all_dups_using', replace
    tempfile matched
    save `matched', replace

    * Run minimerge with fake_first (nickname matching)
    qui minimerge id, extravars(last fake_first) replace(score) merge_code(8) ///
        using_merge_unmatched(`using_unmatched') ///
        master_merge_unmatched(`master_unmatched') ///
        merge_matched(`matched') ///
        all_duplicates_master(`all_dups_master') ///
        all_duplicates_using(`all_dups_using')

    * Check that BOB matched ROBERT via nickname
    use `matched', clear
    local matched_count = _N
    local has_match = (`matched_count' == 1)
    test_assert `has_match' "BOB_should_match_ROBERT_via_nickname"

    test_pass

    *--------------------------------------------------------------------------
    * Test 4: nohyphen_last merge (hyphen/space removal)
    *--------------------------------------------------------------------------
    test_begin "nohyphen_last_merge"

    * Load namevar test data
    use tests/data/namevar_master.dta, clear
    keep if inlist(first, "MARY", "SARAH", "KATE")
    tempfile master_unmatched
    save `master_unmatched'

    use tests/data/namevar_using.dta, clear
    keep if inlist(first, "MARY", "SARAH", "KATE")
    tempfile using_unmatched
    save `using_unmatched'

    * Create empty tempfiles
    keep in 1
    drop if _n > 0
    tempfile all_dups_master
    save `all_dups_master', replace
    tempfile all_dups_using
    save `all_dups_using', replace
    tempfile matched
    save `matched', replace

    * Run minimerge with nohyphen_last
    qui minimerge state, extravars(nohyphen_last first) replace(score) merge_code(11) ///
        using_merge_unmatched(`using_unmatched') ///
        master_merge_unmatched(`master_unmatched') ///
        merge_matched(`matched') ///
        all_duplicates_master(`all_dups_master') ///
        all_duplicates_using(`all_dups_using')

    use `matched', clear

    * MARY (SMITH-JONES -> SMITH JONES) should match
    count if first == "MARY"
    local mary_matched = (r(N) == 1)
    test_assert `mary_matched' "MARY_SMITH-JONES_should_match_SMITH_JONES"

    * SARAH (VAN DER BERG -> VANDERBERG) should match
    count if first == "SARAH"
    local sarah_matched = (r(N) == 1)
    test_assert `sarah_matched' "SARAH_VAN_DER_BERG_should_match_VANDERBERG"

    * KATE should NOT match (BROWN vs TOTALLY-DIFFERENT)
    count if first == "KATE"
    local kate_not_matched = (r(N) == 0)
    test_assert `kate_not_matched' "KATE_BROWN_should_NOT_match_TOTALLY-DIFFERENT"

    test_pass

    *--------------------------------------------------------------------------
    * Test 5: appended_middlelast merge
    *--------------------------------------------------------------------------
    test_begin "appended_middlelast_merge"

    * ANNA: middle="MARIE", last="JOHNSON" -> appended_middlelast="MARIEJOHNSON"
    * Using ANNA: last="MARIE-JOHNSON" -> nohyphen="MARIEJOHNSON" - should match!
    use tests/data/namevar_master.dta, clear
    keep if inlist(first, "ANNA", "NANCY")
    tempfile master_unmatched
    save `master_unmatched'

    use tests/data/namevar_using.dta, clear
    keep if inlist(first, "ANNA", "NANCY")
    tempfile using_unmatched
    save `using_unmatched'

    * Create empty tempfiles
    keep in 1
    drop if _n > 0
    tempfile all_dups_master
    save `all_dups_master', replace
    tempfile all_dups_using
    save `all_dups_using', replace
    tempfile matched
    save `matched', replace

    * Run minimerge with appended_middlelast
    qui minimerge state, extravars(appended_middlelast first) replace(score) merge_code(12) ///
        using_merge_unmatched(`using_unmatched') ///
        master_merge_unmatched(`master_unmatched') ///
        merge_matched(`matched') ///
        all_duplicates_master(`all_dups_master') ///
        all_duplicates_using(`all_dups_using')

    use `matched', clear

    * ANNA should match (MARIE+JOHNSON = MARIE-JOHNSON)
    count if first == "ANNA"
    local anna_matched = (r(N) == 1)
    test_assert `anna_matched' "ANNA_MARIE_JOHNSON_should_match_MARIE-JOHNSON"

    * NANCY should NOT match (SUE+DAVIS != WRONG-NAME)
    count if first == "NANCY"
    local nancy_not_matched = (r(N) == 0)
    test_assert `nancy_not_matched' "NANCY_SUE_DAVIS_should_NOT_match_WRONG-NAME"

    test_pass

    *--------------------------------------------------------------------------
    * Test 6: appended_lastmiddle merge
    *--------------------------------------------------------------------------
    test_begin "appended_lastmiddle_merge"

    * LISA: middle="BETH", last="WILSON" -> appended_lastmiddle="WILSONBETH"
    * Using LISA: last="WILSON-BETH" -> nohyphen="WILSONBETH" - should match!
    use tests/data/namevar_master.dta, clear
    keep if inlist(first, "LISA", "KATE")
    tempfile master_unmatched
    save `master_unmatched'

    use tests/data/namevar_using.dta, clear
    keep if inlist(first, "LISA", "KATE")
    tempfile using_unmatched
    save `using_unmatched'

    * Create empty tempfiles
    keep in 1
    drop if _n > 0
    tempfile all_dups_master
    save `all_dups_master', replace
    tempfile all_dups_using
    save `all_dups_using', replace
    tempfile matched
    save `matched', replace

    * Run minimerge with appended_lastmiddle
    qui minimerge state, extravars(appended_lastmiddle first) replace(score) merge_code(13) ///
        using_merge_unmatched(`using_unmatched') ///
        master_merge_unmatched(`master_unmatched') ///
        merge_matched(`matched') ///
        all_duplicates_master(`all_dups_master') ///
        all_duplicates_using(`all_dups_using')

    use `matched', clear

    * LISA should match (WILSON+BETH = WILSON-BETH)
    count if first == "LISA"
    local lisa_matched = (r(N) == 1)
    test_assert `lisa_matched' "LISA_WILSON_BETH_should_match_WILSON-BETH"

    * KATE should NOT match (BROWN vs TOTALLY-DIFFERENT)
    count if first == "KATE"
    local kate_not_matched = (r(N) == 0)
    test_assert `kate_not_matched' "KATE_BROWN_should_NOT_match_TOTALLY-DIFFERENT"

    test_pass

    *--------------------------------------------------------------------------
    * Summary
    *--------------------------------------------------------------------------
    di as text _n "============================================"
    di as text "MINIMERGE TESTS COMPLETE"
    if $any_test_failed {
        di as error "Some tests FAILED"
    }
    else {
        di as result "All tests PASSED"
    }
    di as text "============================================"

end

* To run: run_minimerge_tests
