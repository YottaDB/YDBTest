#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2022-2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#----------------------------------------------------------------------------------------------------------------------------------------------------------------
# List of subtests of the form "subtestname [author] description"
#-------------------------------------------------------------------------------------
# gtm9269        [bdw]     Tests that the -nowarning compilation option suppresses %YDB-W-DONOBLOCK messages
# missedrevert   [bdw]     Tests that FOR does not SIG-11 due to a missed REVERT
# optimizexecute [bdw]     Tests that the machine listing for an xecute command is optimized
# gtm9244        [bdw]     Tests that ^%JSWRITE outputs variable trees as JSON and returns errors when appropriate
# gtm9260	 [see]	   Tests that MUPIP RUNDOWN cleans up any auxiliary MLock hashtable shared memory segment
# gtm9182        [bdw]     Tests that a MUPIP BACKUP with a backup file path > 255 returns a FILENAMETOOLONG
# gtm5381	 [see]	   Tests that -FULLBLKWRT DB attribute works as anticipated for all three settings {0,1,2}
# gtm9157	 [see]	   Tests that source server is more persistent and gives more details when name resolution fails
# gtm9238	 [see]	   Tests that $ZSTRPLLIM is properly handled regarding STPCRIT/STPOFLOW errors and mimimum values
#----------------------------------------------------------------------------------------------------------------------------------------------------------------

echo "v63012 test starts..."

# List the subtests seperated by spaces under the appropriate environment variable name
setenv subtest_list_common	""
setenv subtest_list_non_replic	"gtm9269 missedrevert optimizexecute gtm9244 gtm9260 gtm9182 gtm5381 gtm9238"
setenv subtest_list_replic	"gtm9157"

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

setenv subtest_exclude_list ""

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
if ("pro" == "$tst_image") then
	# gtm9260 needs to use $ydb_lockhash_n_bits which is only available in dbg mode
	setenv subtest_exclude_list "$subtest_exclude_list gtm9260"
endif

# Bypass gtm9260 on ARMV6L. This is because this test is trying to create a resized M lock hashtable (which is
# allocated in a separate segment) for MUPIP RUNDOWN to cleanup. But on the 32 bit systems like ARMV6L, the lockspace
# is used up a different rate so the standard test, which works fine for 64 bit processes, does not get to the same
# point with 32 bit. Rather than spending a lot of time finding the balance of parameters (lock space and hash bits),
# we've decided that 64 bit testing is sufficient so exclude test if 32 bit (armv6l).
if ("armv6l" == `uname -m`) then
	setenv subtest_exclude_list "$subtest_exclude_list gtm9260"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "v63012 test DONE."
