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
echo "CRASH AND FAIL test Starts..."
setenv gtm_test_dbfill "IMPTP"
setenv test_sleep_sec 45
setenv test_tn_count 20000
# Note that small value gtm_test_sleep_sec_short will not reduce code coverage
# but it will reduce running time
setenv test_sleep_sec_short 15
if ($LFE == "E") then
	setenv gtm_test_jobcnt 3
else
	setenv gtm_test_jobcnt 2
endif
setenv tst_buffsize 1	# Use minimum buffer size for easy buffer overflow

setenv subtest_list "rcvr_failstopcrash_rs src_crash_fo src_failstop_rs"

$gtm_tst/com/submit_subtest.csh
echo "CRASH AND FAIL test DONE."
