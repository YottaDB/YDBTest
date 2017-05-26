#!/usr/local/bin/tcsh -f
set test_number = $1

setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 25
setenv gtm_white_box_test_case_count 1

echo $$ >& dse_parent.pid_$test_number
$DSE << DSE_EOF
	spawn "date > do_dse_flush.started_$test_number"
	spawn "$gtm_tst/com/wait_for_log.csh -log dse.pid_$test_number"
	all -buffer_flush
DSE_EOF
date > do_dse_flush.done_$test_number
