/*******************************************************************************
* test_helpers.do
* Helper programs for megamerge unit tests
*
* Run from project root: do tests/test_helpers.do
*
* Before first use, run: do tests/setup_test_data.do
*******************************************************************************/

capture program drop test_begin
program define test_begin
    args testname
    di as text _n "----------------------------------------"
    di as text "TEST: `testname'"
    di as text "----------------------------------------"
    global current_test "`testname'"
    global test_passed 1
end

capture program drop test_pass
program define test_pass
    di as result "  PASSED: $current_test"
end

capture program drop test_fail
program define test_fail
    args message
    di as error "  FAILED: $current_test"
    di as error "  Reason: `message'"
    global test_passed 0
    global any_test_failed 1
end

capture program drop test_assert
program define test_assert
    args condition message
    if !(`condition') {
        test_fail "`message'"
        exit 9
    }
end

* Initialize test tracking (only if not already initialized)
if "$test_helpers_loaded" != "1" {
    global any_test_failed 0
    global tests_run 0
    global tests_passed 0
    global test_helpers_loaded 1
    di as text _n "Test helpers loaded successfully."
}
