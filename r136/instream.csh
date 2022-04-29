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
#---------------------------------------------------------------------------------------------------------------------------------------------------
# List of subtests of the form "subtestname [author] description"
#----------------------------------------------------------------------------------------------------------------------------------------------------------
# ydb854 [nars]          Test that ICUSYMNOTFOUND error using Simple API does not assert fail
# ydb860 [nars]          Test various code issues identified by fuzz testing
# ydb861 [estess]	 Test $ZATRANSFORM() returns correct value for 2/-2 3rd parm and does not sig-11 with computed input values
# ydb869 [nars]          Test boolean expressions involving huge numeric literals issue NUMOFLOW error (and not SIG-11)
#----------------------------------------------------------------------------------------------------------------------------------------------------------

echo "r136 test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic "ydb854 ydb860 ydb861 ydb869"
setenv subtest_list_replic     ""

if ($?test_replic == 1) then
       setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
       setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

setenv subtest_exclude_list    ""

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "r136 test DONE."
