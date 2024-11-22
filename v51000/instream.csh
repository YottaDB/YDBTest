#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2017-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
# Portions Copyright (c) Fidelity National			#
# Information Services, Inc. and/or its subsidiaries.		#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
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
#
if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

setenv subtest_exclude_list ""

if ("ENCRYPT" == "$test_encryption" ) then
	# The below 2 subtests are very sensitive to timing between mupip backup process and concurrent updates
	# (see the comment "so that we have time to mess with them") in the respective subtest driver scripts).
	# Running them with -encrypt destroys the timing and causes these tests to fail almost always.
	# Since these 2 subtests test an obscure error scenario, they are not that important to run with -encrypt
	# and so we disable them with -encrypt.
	setenv subtest_exclude_list "$subtest_exclude_list mu_bkup_change_permission mu_bkup_stop"
endif

$gtm_tst/com/submit_subtest.csh
echo "V51000 test DONE."
