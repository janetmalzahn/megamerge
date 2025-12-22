/*******************************************************************************
* test_extrname_clean.do
* Unit tests for extrname_clean.ado
*
* Note: Requires extrname to be installed (ssc install extrname)
*
* Run from project root:
*   run tests/test_extrname_clean.do
*   run_extrname_clean_tests
*******************************************************************************/

* Load dependencies
run tests/test_helpers.do
run extrname_clean.ado

capture program drop run_extrname_clean_tests
program define run_extrname_clean_tests

    di as text _n "============================================"
    di as text "RUNNING TESTS: extrname_clean.ado"
    di as text "============================================"

    * Check if extrname is installed
    capture which extrname
    if _rc != 0 {
        di as error "extrname not installed. Run: ssc install extrname"
        di as error "Skipping extrname_clean tests."
        exit
    }

    *--------------------------------------------------------------------------
    * Test 1: Basic name parsing works
    *--------------------------------------------------------------------------
    test_begin "basic_name_parsing"

    clear
    set obs 1
    gen str50 fullname = "SMITH, JOHN MICHAEL"

    qui extrname_clean fullname

    * Check first name extracted
    local first_correct = (first[1] == "JOHN")
    test_assert `first_correct' "First_name_should_be_JOHN"

    * Check last name extracted
    local last_correct = (last[1] == "SMITH")
    test_assert `last_correct' "Last_name_should_be_SMITH"

    * Check middle name extracted
    local middle_correct = (middle[1] == "MICHAEL")
    test_assert `middle_correct' "Middle_name_should_be_MICHAEL"

    test_pass

    *--------------------------------------------------------------------------
    * Test 2: Two-letter first names (ED, AL, etc.) not treated as initials
    *--------------------------------------------------------------------------
    test_begin "two_letter_first_names"

    clear
    set obs 3
    gen str50 fullname = ""
    replace fullname = "SMITH, ED" in 1
    replace fullname = "JONES, AL" in 2
    replace fullname = "BROWN, JO" in 3

    qui extrname_clean fullname

    * ED should be kept as ED, not E.D.
    local ed_correct = (first[1] == "ED")
    test_assert `ed_correct' "ED_should_stay_as_ED"

    local al_correct = (first[2] == "AL")
    test_assert `al_correct' "AL_should_stay_as_AL"

    local jo_correct = (first[3] == "JO")
    test_assert `jo_correct' "JO_should_stay_as_JO"

    test_pass

    *--------------------------------------------------------------------------
    * Test 3: Creates extrname_clean indicator variable
    *--------------------------------------------------------------------------
    test_begin "creates_indicator_variable"

    clear
    set obs 1
    gen str50 fullname = "SMITH, JOHN"

    * Verify indicator doesn't exist before
    capture confirm variable extrname_clean
    local no_indicator_before = (_rc != 0)
    test_assert `no_indicator_before' "extrname_clean_should_not_exist_before"

    qui extrname_clean fullname

    * Verify indicator exists after
    capture confirm variable extrname_clean
    local indicator_exists = (_rc == 0)
    test_assert `indicator_exists' "extrname_clean_should_exist_after"

    test_pass

    *--------------------------------------------------------------------------
    * Test 4: Names are uppercased
    *--------------------------------------------------------------------------
    test_begin "names_uppercased"

    clear
    set obs 1
    gen str50 fullname = "smith, john michael"

    qui extrname_clean fullname

    local first_upper = (first[1] == "JOHN")
    test_assert `first_upper' "First_name_should_be_uppercased"

    local last_upper = (last[1] == "SMITH")
    test_assert `last_upper' "Last_name_should_be_uppercased"

    test_pass

    *--------------------------------------------------------------------------
    * Test 5: VAN prefix handling
    *--------------------------------------------------------------------------
    test_begin "van_prefix_handling"

    clear
    set obs 1
    gen str50 fullname = "VAN DER BERG, JOHN"

    qui extrname_clean fullname

    * Check that name was processed
    capture confirm variable first
    local has_first = (_rc == 0)
    test_assert `has_first' "Should_have_first_variable"

    capture confirm variable last
    local has_last = (_rc == 0)
    test_assert `has_last' "Should_have_last_variable"

    test_pass

    *--------------------------------------------------------------------------
    * Test 6: Handles suffix
    *--------------------------------------------------------------------------
    test_begin "handles_suffix"

    clear
    set obs 1
    gen str50 fullname = "SMITH, JOHN JR"

    qui extrname_clean fullname

    capture confirm variable suffix
    local has_suffix = (_rc == 0)
    test_assert `has_suffix' "Should_have_suffix_variable"

    test_pass

    *--------------------------------------------------------------------------
    * Summary
    *--------------------------------------------------------------------------
    di as text _n "============================================"
    di as text "EXTRNAME_CLEAN TESTS COMPLETE"
    if $any_test_failed {
        di as error "Some tests FAILED"
    }
    else {
        di as result "All tests PASSED"
    }
    di as text "============================================"

end

* To run: run_extrname_clean_tests
