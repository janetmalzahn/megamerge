/*******************************************************************************
* test_checkdrop.do
* Unit tests for checkdrop.ado
*
* Run from project root: do tests/test_checkdrop.do
*******************************************************************************/

clear all
run tests/test_helpers.do
run checkdrop.ado

capture program drop run_checkdrop_tests
program define run_checkdrop_tests

    di as text _n "============================================"
    di as text "RUNNING TESTS: checkdrop.ado"
    di as text "============================================"

    *--------------------------------------------------------------------------
    * Test 1: Drops existing variable
    *--------------------------------------------------------------------------
    test_begin "checkdrop_drops_existing_variable"

    clear
    set obs 2
    gen x = _n
    gen y = _n * 2
    gen z = _n * 3

    * Verify y exists before
    capture confirm variable y
    local y_exists_before = (_rc == 0)
    test_assert `y_exists_before' "Variable_y_should_exist_before_checkdrop"

    * Run checkdrop
    checkdrop y

    * Verify y no longer exists
    capture confirm variable y
    local y_dropped = (_rc != 0)
    test_assert `y_dropped' "Variable_y_should_be_dropped"

    * Verify x and z still exist
    capture confirm variable x
    local x_exists = (_rc == 0)
    test_assert `x_exists' "Variable_x_should_still_exist"

    capture confirm variable z
    local z_exists = (_rc == 0)
    test_assert `z_exists' "Variable_z_should_still_exist"

    test_pass

    *--------------------------------------------------------------------------
    * Test 2: Silently skips non-existent variable
    *--------------------------------------------------------------------------
    test_begin "checkdrop_skips_nonexistent_variable"

    clear
    set obs 2
    gen x = _n
    gen y = _n * 2

    * Run checkdrop on non-existent variable - should not error
    capture checkdrop nonexistent_var
    local no_error = (_rc == 0)
    test_assert `no_error' "checkdrop_should_not_error_on_nonexistent"

    * Verify original variables still exist
    capture confirm variable x
    local x_exists = (_rc == 0)
    test_assert `x_exists' "Variable_x_should_still_exist"

    capture confirm variable y
    local y_exists = (_rc == 0)
    test_assert `y_exists' "Variable_y_should_still_exist"

    test_pass

    *--------------------------------------------------------------------------
    * Test 3: Handles multiple variables
    *--------------------------------------------------------------------------
    test_begin "checkdrop_handles_multiple_variables"

    clear
    set obs 2
    gen a = _n
    gen b = _n * 2
    gen c = _n * 3
    gen d = _n * 4

    * Drop some existing (b, d) and some non-existent (fake1, fake2)
    checkdrop b fake1 d fake2

    * Verify b and d are dropped
    capture confirm variable b
    local b_dropped = (_rc != 0)
    test_assert `b_dropped' "Variable_b_should_be_dropped"

    capture confirm variable d
    local d_dropped = (_rc != 0)
    test_assert `d_dropped' "Variable_d_should_be_dropped"

    * Verify a and c still exist
    capture confirm variable a
    local a_exists = (_rc == 0)
    test_assert `a_exists' "Variable_a_should_still_exist"

    capture confirm variable c
    local c_exists = (_rc == 0)
    test_assert `c_exists' "Variable_c_should_still_exist"

    test_pass

    *--------------------------------------------------------------------------
    * Test 4: Works with dataset option
    *--------------------------------------------------------------------------
    test_begin "checkdrop_with_dataset_option"

    clear
    set obs 2
    gen merge_code = _n
    gen matched = 3

    * Run with dataset option
    checkdrop merge_code, dataset(mydata)

    * Verify variable was dropped
    capture confirm variable merge_code
    local mc_dropped = (_rc != 0)
    test_assert `mc_dropped' "Variable_merge_code_should_be_dropped"

    test_pass

    *--------------------------------------------------------------------------
    * Summary
    *--------------------------------------------------------------------------
    di as text _n "============================================"
    di as text "CHECKDROP TESTS COMPLETE"
    if $any_test_failed {
        di as error "Some tests FAILED"
    }
    else {
        di as result "All tests PASSED"
    }
    di as text "============================================"

end

* To run: run_checkdrop_tests
