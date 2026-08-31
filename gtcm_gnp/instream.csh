#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright 2002, 2014 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2023-2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
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
# msgvalidate	[YDB#1101] Test that the GT.CM server refuses malformed messages instead of overrunning
#		its buffers, and keeps serving afterwards

echo "GT.CM tests start..."

setenv tst_gtcm_trace 1
setenv gtm_test_use_V6_DBs 0	# Disable V6 DB mode due to difficulties with remote systems having same V6 version to create DBs
# crash_client subtest is removed, since killclwithlock tests the same functionality
# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     "basic locks_gtcm locks_client_first locks_two_clients crash_server multi_proc_jnl namelevel killsvrwithlock killclwithlock triggers msgvalidate"
setenv subtest_list_non_replic ""
setenv subtest_list_replic     ""

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif
if ("ENCRYPT" == "$test_encryption") then
	setenv subtest_list "$subtest_list encryption_err"
else
endif

$gtm_tst/com/submit_subtest.csh
echo "Tests done."
