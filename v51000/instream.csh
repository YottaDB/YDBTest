#!/usr/local/bin/tcsh -f
#
# ------------------------------------------------------------------------------
# for bugs fixed in V50000D and V51000
# ------------------------------------------------------------------------------
# C9E12002698 [Narayanan] KILL of globals in TP transactions cause database damage and assert failures
# D9F11002577 [Narayanan] Patterns mixed with alternations do not work as expected
# D9G01002587 [Narayanan] Errors during MUPIP LOAD with a fillfactor of less than 100%
# D9F11002578 [Narayanan] MUPIP SET -FLUSH=xxx does not work
# D9G01002589 [Narayanan] MUPIP SET and GDE cannot set LOCK_SPACE to more than 1000
# D9G01002590 [Narayanan] GDE incorrectly reads the template parameter STDNULLCOLL
# D9G03002599 [Narayanan] GTM does not detect (and stop) external reference to second replicated instance
# D9F07002561 [Narayanan] Use heartbeat timer to check and close open older generation journal files
# D9G01002592 [Narayanan] MUPIP LOAD arbitrarily low record limit impedes large ZWR loads
# mu_bkup_change_permission [Balaji] This subtest addresses TR-D9G02-002597.
#	MUPIP backup fails when the previous backup is aborted due to temp file permission issues.
# mu_bkup_stop [Balaji] This subtest addresses TR-D9G02-002597.
#	MUPIP backup fails when the previous backup is MUPIP STOPped.
# D9E08002477 [Narayanan] JOB Interrupt puts IBS servers into a non functional state and breaks outofband
#
# The fixes for all the above tests were released in V5.0-000D even though they are part of "v51000" test.
# Tests for fixes that get released in V5.1-000 need to be added below
#
# ------------------------------------------------------------------------------
#
# The first subtest to be included in subtest_list_replic below will necessitate 
#	a) a change to suite.txt to enable the test to be run with replication 
#	b) a change to outref.txt to handle replication as well as non-replication test runs using ##TEST_AWK macros
#
echo "V51000 test starts..."
setenv subtest_list_common " "
setenv subtest_list_replic " "
setenv subtest_list_non_replic "C9E12002698 D9F11002577 D9G01002587 D9F11002578 D9G01002589 D9G01002590 D9G03002599 D9F07002561 "
setenv subtest_list_non_replic "$subtest_list_non_replic D9G01002592 mu_bkup_change_permission mu_bkup_stop D9E08002477"
setenv subtest_list_non_replic_FE " "
#
if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
	if ("L" != $LFE) then
		setenv subtest_list "$subtest_list $subtest_list_non_replic_FE"
	endif
endif
if ($?gtm_test_temporary_disable) then
	setenv subtest_exclude_list "mu_bkup_stop"
endif
$gtm_tst/com/submit_subtest.csh
echo "V51000 test DONE."
