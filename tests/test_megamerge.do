/*******************************************************************************
* test_megamerge.do
* Integration tests for megamerge.ado
*
* Before running, ensure test data exists:
*   do tests/setup_test_data.do
*
* Run from project root:
*   run tests/test_megamerge.do
*   run_megamerge_tests
*******************************************************************************/

* Load dependencies
run tests/test_helpers.do
run checkdrop.ado
run replace_nicknames.ado
run minimerge.ado
run megamerge.ado

capture program drop run_megamerge_tests
program define run_megamerge_tests

    di as text _n "============================================"
    di as text "RUNNING TESTS: megamerge.ado (integration)"
    di as text "============================================"

    * Check if test data exists
    capture confirm file "tests/data/simple_master.dta"
    if _rc != 0 {
        di as error "Test data not found. Run: do tests/setup_test_data.do"
        exit
    }

    *--------------------------------------------------------------------------
    * Test 1: Basic merge produces expected variables
    *--------------------------------------------------------------------------
    test_begin "basic_merge_produces_variables"

    use tests/data/simple_master.dta, clear

    megamerge id using tests/data/simple_using.dta

    * Check merge_code exists
    capture confirm variable merge_code
    local has_merge_code = (_rc == 0)
    test_assert `has_merge_code' "Should_have_merge_code_variable"

    * Check matched exists
    capture confirm variable matched
    local has_matched = (_rc == 0)
    test_assert `has_matched' "Should_have_matched_variable"

    test_pass

    *--------------------------------------------------------------------------
    * Test 2: Exact matches get merge_code 0
    *--------------------------------------------------------------------------
    test_begin "exact_matches_code_0"

    use tests/data/simple_master.dta, clear

    megamerge id using tests/data/simple_using.dta

    * JOHN SMITH should match exactly (merge_code 0)
    count if first == "JOHN" & last == "SMITH" & merge_code == 0
    local john_matched = (r(N) == 1)
    test_assert `john_matched' "JOHN_SMITH_should_have_merge_code_0"

    * JANE DOE should match exactly (merge_code 0)
    count if first == "JANE" & last == "DOE" & merge_code == 0
    local jane_matched = (r(N) == 1)
    test_assert `jane_matched' "JANE_DOE_should_have_merge_code_0"

    test_pass

    *--------------------------------------------------------------------------
    * Test 3: Nickname matching works (merge_code 8)
    *--------------------------------------------------------------------------
    test_begin "nickname_matching"

    use tests/data/simple_master.dta, clear

    megamerge id using tests/data/simple_using.dta

    * BOB JONES in master should match ROBERT JONES in using
    count if first == "BOB" & last == "JONES" & merge_code == 8
    local bob_matched = (r(N) == 1)
    test_assert `bob_matched' "BOB_should_match_ROBERT_via_nickname"

    test_pass

    *--------------------------------------------------------------------------
    * Test 4: Matched variable values are correct
    *--------------------------------------------------------------------------
    test_begin "matched_variable_values"

    use tests/data/simple_master.dta, clear

    megamerge id using tests/data/simple_using.dta

    * matched == 3 means matched
    count if matched == 3
    local some_matched = (r(N) > 0)
    test_assert `some_matched' "Should_have_some_matched_observations"

    test_pass

    *--------------------------------------------------------------------------
    * Test 5: Duplicate handling - duplicates get code 101/201
    *--------------------------------------------------------------------------
    test_begin "duplicate_handling"

    use tests/data/duplicate_master.dta, clear

    megamerge state using tests/data/duplicate_using.dta

    * The JOHN SMITHs should be marked as duplicates (101 or stay unmatched)
    count if first == "JOHN" & last == "SMITH" & inlist(merge_code, 100, 101)
    local john_dup_count = r(N)
    * Should have at least some marked as duplicates or unmatched
    local johns_handled = (`john_dup_count' >= 2)
    test_assert `johns_handled' "Duplicate_JOHNs_should_be_handled"

    * JANE DOE should match (only one in each dataset)
    count if first == "JANE" & last == "DOE" & merge_code == 0
    local jane_matched = (r(N) == 1)
    test_assert `jane_matched' "Unique_JANE_should_match"

    test_pass

    *--------------------------------------------------------------------------
    * Test 6: keepmerges option works
    *--------------------------------------------------------------------------
    test_begin "keepmerges_option"

    use tests/data/simple_master.dta, clear

    * Only run merge 0 (exact match)
    megamerge id using tests/data/simple_using.dta, keepmerges(0)

    * BOB should NOT match (nickname matching is merge 8)
    count if first == "BOB" & last == "JONES" & merge_code == 0
    local bob_not_matched_0 = (r(N) == 0)
    test_assert `bob_not_matched_0' "BOB_should_not_match_with_only_merge_0"

    test_pass

    *--------------------------------------------------------------------------
    * Test 7: omitmerges option works
    *--------------------------------------------------------------------------
    test_begin "omitmerges_option"

    use tests/data/simple_master.dta, clear

    * Skip merge 8 (nickname matching)
    megamerge id using tests/data/simple_using.dta, omitmerges(8)

    * BOB should NOT match via nickname
    count if first == "BOB" & last == "JONES" & merge_code == 8
    local bob_not_code_8 = (r(N) == 0)
    test_assert `bob_not_code_8' "BOB_should_not_have_merge_code_8"

    test_pass

    *--------------------------------------------------------------------------
    * Test 8: Full dataset merge runs without error
    *--------------------------------------------------------------------------
    test_begin "full_merge_no_error"

    use tests/data/master_test.dta, clear

    capture megamerge state district using tests/data/using_test.dta
    local no_error = (_rc == 0)
    test_assert `no_error' "Full_merge_should_complete_without_error"

    test_pass

    *--------------------------------------------------------------------------
    * Test 9: Hyphen-space normalization allows cross-matching
    *--------------------------------------------------------------------------
    test_begin "hyphen_space_normalization"

    * Use existing namevar test data which has SMITH-JONES vs SMITH JONES
    use tests/data/namevar_master.dta, clear
    megamerge state using tests/data/namevar_using.dta

    * SMITH-JONES should match SMITH JONES (hyphen normalized to space)
    count if first == "MARY" & merge_code < 100
    local mary_matched = (r(N) == 1)
    test_assert `mary_matched' "SMITH-JONES_should_match_SMITH_JONES"

    test_pass

    *--------------------------------------------------------------------------
    * Test 10: Last name with single word still works
    *--------------------------------------------------------------------------
    test_begin "single_word_last_name"

    use tests/data/simple_master.dta, clear
    megamerge id using tests/data/simple_using.dta

    * Simple last names should still match
    count if first == "JOHN" & last == "SMITH" & merge_code == 0
    local john_matched = (r(N) == 1)
    test_assert `john_matched' "Single_word_last_name_should_match"

    test_pass

    *--------------------------------------------------------------------------
    * Summary
    *--------------------------------------------------------------------------
    di as text _n "============================================"
    di as text "MEGAMERGE TESTS COMPLETE"
    if $any_test_failed {
        di as error "Some tests FAILED"
    }
    else {
        di as result "All tests PASSED"
    }
    di as text "============================================"

end

* To run: run_megamerge_tests
