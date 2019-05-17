#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018-2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#---------------------------------------------------------------------------------------------------------------------------------------------------
# List of subtests of the form "subtestname [author] description"
#----------------------------------------------------------------------------------------------------------------------------------------------------------
# ydb430	   [nars]  Test that $ZTRIGGER and MUPIP TRIGGER work with numeric subscripts having a decimal point
#                          Also test that triggers for ^x(2) or ^x(2.0) or ^x("2") are treated as identical.
# pseudoBank	   [mmr]   Test of simulated banking transactions using M with 10 processes/jobs
#----------------------------------------------------------------------------------------------------------------------------------------------------------

echo "r126 test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic ""
setenv subtest_list_non_replic "$subtest_list_non_replic ydb430 pseudoBank randomWalk ydb431"
setenv subtest_list_replic     ""

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

setenv subtest_exclude_list    ""

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "r126 test DONE."
