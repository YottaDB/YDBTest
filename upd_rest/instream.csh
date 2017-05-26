#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#
echo "upd_rest test starts..."
setenv tst_buffsize 1048576
# On AIX, we have seen that a low journal buffer size causes the update process to do frequent journal flush while holding
# crit. This causes the concurrent read process(es) to take a lot more time to complete than what is expected. To work-around
# this, increase the journal buffer size (from 128 to 2308 => 60K to 1MB). See <upd_rest_long_running_jobs>/resolution_v1.txt
# for details. Even though this test has failed before ONLY on AIX, increase the journal buffer size unconditionally to make
# the test run faster (on other boxes).
if ($?tst_jnl_str) then		# there is no reason why this variable should be undefined
	setenv tst_jnl_str "$tst_jnl_str,buff=2308"
else
	echo "TEST-E-UPDREST tst_jnl_str should have been set at this point. Exiting.."
	exit 1
endif
if ($LFE == "E") then
	setenv test_sleep_sec_short 30
	setenv test_sleep_sec 120
	setenv gtm_test_jobcnt 5
else
	setenv test_sleep_sec_short 30
	setenv test_sleep_sec 60
	setenv gtm_test_jobcnt 2
endif
setenv subtest_list "fix_tp var_tp"
$gtm_tst/com/submit_subtest.csh
echo "upd_rest test DONE."
#
##################################
###          END               ###
##################################
