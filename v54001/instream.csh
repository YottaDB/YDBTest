#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2010-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#-------------------------------------------------------------------------------------
# List of subtests of the form "subtestname [author] description"
# C9K04003254      [MikeC]   test view "jnlflush" with multiple jobs
# C9K02003237      [groverh] Test gtm_procstuckexec for semaphore operations
# D9C10002234      [rog]     test $QLENGTH() and $QSUBSCRIPT() with $[Z]CHAR() input
# C9K04003264      [rog]     Allow $Z* byte functions on VMS that were previously UNIX-only
# D9J07002730      [rog]     Check return from MUPIP RUNDOWN where database is missing
# updproc_nullsubs [s7kk]    Test that NULSUBSC error is issued by update process
# D9E12002513      [rog]     Add test for zhelp running with M profiling
# D9C05002098      [rog] test JOB command for proper behavior with missing and short actualists
# D9C05002098      [rog]     test JOB command for proper behavior with missing and short actualists
# C9K05003272      [nars]    MUPIP REPLIC SHOWBACKLOG should show backlog even if source server is down
# C9K03003247 	   [s7kk]    test that libgcrypt warnings are not issued in the operator log
# C9K05003270 	   [s7kk]    Test that GT.M correctly handles cases where the snapshot file is not readable
# C9J04003116 	   [s7kk]    Test that MUPIP SET -JOURNAL works even in case of JNLMOVED error
#-------------------------------------------------------------------------------------

echo "v54001 test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     "C9J04003116"
setenv subtest_list_non_replic "C9K04003254 D9C10002234 C9K04003264 D9J07002730 D9E12002513 D9C05002098 C9K03003247 C9K05003270 C9K02003237"
setenv subtest_list_replic     "updproc_nullsubs C9K05003272"

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
setenv subtest_exclude_list ""

if ("NON_ENCRYPT" == "$test_encryption") then
	setenv subtest_exclude_list "$subtest_exclude_list C9K03003247"
endif

# Filter out tests requiring specific gg-user setup, if the setup is not available
if ($?gtm_test_noggusers) then
	setenv subtest_exclude_list "$subtest_exclude_list C9K05003270"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "v54001 test DONE."
