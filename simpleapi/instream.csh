#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
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
#-------------------------------------------------------------------------------------
# lvnset       [nars]   Test of ydb_set_s() function for Local variables in the simpleAPI
# lvnsetstress [nars]   Stress test of ydb_set_s() function for Local variables in the simpleAPI
# stresstest   [nars]   Stress test of all ydb_*() functions in the simpleAPI
# gvnset       [estess] Test of ydb_set_s() function for Global variables in the simpleAPI
# isvset       [estess] Test of ydb_set_s() function for Intrinsic Special Variables in the simpleAPI
# tp           [nars]   Test of ydb_tp_s() function in the simpleAPI
# transid      [nars]   Test that transid specified in ydb_tp_s() does go into journal file
#-------------------------------------------------------------------------------------

echo "simpleapi test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic "lvnset lvnsetstress stresstest gvnset isvset tp transid"
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

echo "simpleapi test DONE."
