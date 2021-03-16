#!/usr/local/bin/tcsh -f

#################################################################
#								#
# Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	#
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
# gtm9206               [bdw]            Test that MUPIP LOAD can correctly handle 64 bit values for -begin and -end
#----------------------------------------------------------------------------------------------------------------------------------------------------------------


echo "v63010 test starts..."

# List the subtests seperated by sspaces under the appropriate environment variable name
setenv subtest_list_common	""
setenv subtest_list_non_replic "gtm9206"
setenv subtest_list_replic	""

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

setenv subtest_exclude_list ""
if("pro" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list "
endif

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
if ("pro" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list "
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "v63010 test DONE."
