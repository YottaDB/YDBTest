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
# gtm9147		[bdw]    Tests that MUPIP SET -JOURNAL -BUFFSIZE accepts values up to 1Mi blocks
# gtm9287        	[jv]     Fix syntax error message line number reporting for large M files
# gtm8793	 	[see]	 Test new EXITSTATUS error given when procstuckexec script returns non-zero return code
# gtm9311	 	[see]	 Test that calling ^%YGBLSTAT does not pollute the x and d local variables
# gtm9295	 	[see]	 Test multiple fixes to $ZTRANSLATE()/$TRANSLATE()
# gtm9293        	[jv]     Test that an empty string result from argument indirection is accepted
# gtm9313	 	[see]	 Test that $ORDER() issued with subscripted var with boolean expr using gvname gives correct answer
# gtm8772ANDgtm8784	[see]	 Combined test for gtm8872 and gtm8784 to test what update requests do when freeze -online in effect
# gtm8838	 	[see]	 Test that WFR, BUS and BTS statistics are being reported for $VIEW, MUPIP DUMPFHEAD, ^%PEEKBYNAME, and ^%YGBLSTAT
# gtm9252		[see,nars] Test that when 2 processes open a read-only file, they don't cause a SYSCALL error in syslog
#----------------------------------------------------------------------------------------------------------------------------------------------------------------

echo "v63013 test starts..."

# List the subtests seperated by spaces under the appropriate environment variable name
setenv subtest_list_common	""
setenv subtest_list_non_replic "gtm9147 gtm9287 gtm8793 gtm9311 gtm9295 gtm9293 gtm9313 gtm8772ANDgtm8784 gtm8838 gtm9252"
setenv subtest_list_replic	""

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

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "v63013 test DONE."
