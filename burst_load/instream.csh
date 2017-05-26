#!/usr/local/bin/tcsh -f
#
# This was originally intended for performance test. But we need some rework for that.
# For now it is a functionality test. So, test_backlog_time and gtm_test_jobcnt are reduced
echo "BURST_LOAD Test Starts..."
setenv gtm_test_dbfill "IMPTP"
# When this test is changed to do only performance test use either TP or non-TP always for a subtest
@ randnum = `$gtm_exe/mumps -run rand 100 1 1`
if ($randnum < 50) then
	setenv gtm_test_tp "TP"
else
	setenv gtm_test_tp "NON_TP"
endif
if ($LFE == "E") then
	setenv test_backlog_time 60
	setenv gtm_test_jobcnt 3
else
	setenv test_backlog_time 60
	setenv gtm_test_jobcnt 2
endif

# For all subtests the buffer size is 1 MB and always keep log files
setenv tst_buffsize 1048576
unsetenv LOG_UPDATES
unsetenv test_updproc

setenv subtest_list "no_backup onlnbkup_rcvr onlnbkup_src_a onlnbkup_src_b"

$gtm_tst/com/submit_subtest.csh
echo "BURST_LOAD Test Ends..."

