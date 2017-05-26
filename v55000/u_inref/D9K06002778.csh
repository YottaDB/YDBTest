#!/usr/local/bin/tcsh -f

# Test case for D9K06-002778 - white box so debug only.
# Corrupts mpc in a previous frame and makes sure error processing
# can deal with it (caused many GTMASSERTs before V55000).

setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 54
setenv gtm_white_box_test_case_count 0

$gtm_dist/mumps -run D9K06002778
