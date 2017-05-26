#!/usr/local/bin/tcsh
#################################################################
#								#
#	Copyright 2002, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# encryption_err [s7kr] Test whether unsetting the gtm_passwd before starting the GT.CM servers issues appropriate error when
# 	 	    updates are made in the client
# triggers	[S7KK] Test that GT.CM Server skips triggers

echo "Testing GT.CM..."

setenv tst_gtcm_trace 1
# crash_client subtest is removed, since killclwithlock tests the same functionality
setenv subtest_list "basic locks_gtcm locks_client_first locks_two_clients crash_server "
setenv subtest_list "$subtest_list multi_proc_jnl namelevel killsvrwithlock killclwithlock triggers"
if ("ENCRYPT" == "$test_encryption") then
	setenv subtest_list "$subtest_list encryption_err"
else
endif

$gtm_tst/com/submit_subtest.csh
echo "Done..."
