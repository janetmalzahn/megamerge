/*******************************************************************************
* run_tests.do
* Master test runner for megamerge
*
* Run from project root: do tests/run_tests.do
*
* Before first run, create test data: do tests/setup_test_data.do
*******************************************************************************/

clear all

* Reset test helpers flag so it initializes fresh
global test_helpers_loaded 0

di as text _n "============================================"
di as text "MEGAMERGE TEST SUITE"
di as text "============================================"

* Load test helpers
run tests/test_helpers.do

* Load all megamerge programs
run checkdrop.ado
run replace_nicknames.ado
run extrname_clean.ado
run minimerge.ado
run megamerge.ado

* Load all test files
run tests/test_checkdrop.do
run tests/test_replace_nicknames.do
run tests/test_extrname_clean.do
run tests/test_minimerge.do
run tests/test_megamerge.do

* Run all tests
run_checkdrop_tests
run_replace_nicknames_tests
run_extrname_clean_tests
run_minimerge_tests
run_megamerge_tests

* Final summary
di as text _n "============================================"
di as text "ALL TESTS COMPLETE"
if $any_test_failed {
    di as error "SOME TESTS FAILED"
}
else {
    di as result "ALL TESTS PASSED"
}
di as text "============================================"
