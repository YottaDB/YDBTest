#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2015 Fidelity National Information Services, Inc	#
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
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
#   basic [mohammed] Tests most different args, preallocation, and some retvals
#   retvals [berwyn] Tests all possible returnable values and check invalid ones are invalid
#   ydbtypes [berwyn] Tests all possible ydb_xxx_t and standard C types as parameters and check invalid ones are invalid
#-------------------------------------------------------------------------------------

echo "xcall test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic "basic retvals ydbtypes"
setenv subtest_list_replic     ""

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
setenv subtest_exclude_list	""

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "xcall test DONE."

