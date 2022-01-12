#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2021-2022 YottaDB LLC and/or its subsidiaries.	#
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
# gtm8398		[bdw]		 Tests setting a segment's extension_count to more than 65355 blocks and extending it with MUPIP EXTEND
# gtm9215		[bdw]		 Tests that setting an ISV to a string starting with 1E or 1e and writing it does not NUMOFLOW
# gtm9226		[bdw]		 Tests that $translate sets strings to the correct length when passed a malformed character as an argument
#----------------------------------------------------------------------------------------------------------------------------------------------------------------

echo "v63011 test starts..."

# List the subtests seperated by sspaces under the appropriate environment variable name
setenv subtest_list_common	""
setenv subtest_list_non_replic "gtm8398 gtm9215 gtm9226"
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

echo "v63011 test DONE."
