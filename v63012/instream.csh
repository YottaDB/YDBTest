#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
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
#----------------------------------------------------------------------------------------------------------------------------------------------------------------

echo "v63012 test starts..."

# List the subtests seperated by spaces under the appropriate environment variable name
setenv subtest_list_common	""
setenv subtest_list_non_replic "gtm9269 missedrevert optimizexecute gtm9244 gtm9260"
setenv subtest_list_replic	""

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

setenv subtest_exclude_list ""

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
if ("pro" == "$tst_image") then
	# optimizexecute is disabled on pro because "yottadb -machine -lis=" is only implemented for dbg builds
	setenv subtest_exclude_list "$subtest_exclude_list optimizexecute"
	# gtm9260 needs to use $ydb_lockhash_n_bits which is only available in dbg mode
	setenv subtest_exclude_list "$subtest_exclude_list gtm9260"
endif

if ("dbg" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "v63012 test DONE."
