#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2022-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#----------------------------------------------------------------------------------------------------------------------------------
# List of subtests of the form "subtestname [author] description"
#-------------------------------------------------------------------------------------
# gtm9321	[jv]		Test that $ORDER(<indirection>,<literal>) maintains correct $REFERENCE
# gtm7628	[estess]	Verify source/receiver servers can handle a 64GB jnlpool/recvpool
# gtm9328	[estess]	Verify cannot nest $ZINTERRUPT
# gtm9329	[estess]	Verify $ZTIMEOUT fixes made for this issue
# gtm9331	[estess]	Verify $ZTIMEOUT does wake up appropriately when external call steals the wakeup signal
# gtm8863b	[estess]	Verify toggle stats operate correctly
# gtm9102	[nars]		Verify MUPIP FREEZE is consistent across regions
# gtm8800	[estess]	Verify MUPIP FTOK and MUPIP SEMAPHORE work with new options (-ID, -ONLY, and -NOHEADER)
#----------------------------------------------------------------------------------------------------------------------------------

echo "v63014 test starts..."

# List the subtests seperated by spaces under the appropriate environment variable name
setenv subtest_list_common	""
setenv subtest_list_non_replic "gtm9321 gtm9328 gtm9329 gtm9331 gtm8863b gtm9102"
setenv subtest_list_replic     "gtm7628 gtm8800"

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

setenv subtest_exclude_list ""

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
if ("pro" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list"
endif

if ("dbg" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list"
endif

if ("0" == "$ydb_allow64GB_jnlpool") then
	setenv subtest_exclude_list "$subtest_exclude_list gtm7628"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "v63014 test DONE."
