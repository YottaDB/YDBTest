#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.	#
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
# lvnset       [nars]        Test of ydb_set_s() function for Local variables in the simpleAPI
# lvnsetstress [nars]        Stress test of ydb_set_s() function for Local variables in the simpleAPI
# stresstest   [nars]        Stress test of all ydb_*() functions in the simpleAPI
# gvnset       [estess,nars] Test of ydb_set_s() function for Global variables in the simpleAPI
# isvset       [estess]      Test of ydb_set_s() function for Intrinsic Special Variables in the simpleAPI
# tp           [nars]        Test of ydb_tp_s() function in the simpleAPI
# transid      [nars]        Test that transid specified in ydb_tp_s() does go into journal file
# lvnget       [estess,nars] Test of ydb_get_s() function for local variables in the simpleAPI
# gvnget       [estess,nars] Test of ydb_get_s() function for global variables in the simpleAPI
# isvget       [estess]      Test of ydb_get_s() function for ISVs in the simpleAPI
# threen1g     [nars]        Use simpleAPI to find the maximum number of steps for the 3n+1 problem
#                            for all integers through two input integers.
# wordfreq     [nars]        Use simpleAPI to find the frequency of words in an input text file
# gvnsubsnext  [nars]        Test of ydb_subscript_next_s() function for global variables in the simpleAPI
# gvnsubsprev  [nars]        Test of ydb_subscript_previous_s() function for global variables in the simpleAPI
# gvnnodenext  [nars]        Test of ydb_node_next_s() function for global variables in the simpleAPI
# gvnnodeprev  [nars]        Test of ydb_node_previous_s() function for global variables in the simpleAPI
# gvndata      [nars]        Test of ydb_data_s() function for global variables in the simpleAPI
# gvnincr      [nars]        Test of ydb_incr_s() function for global variables in the simpleAPI
# lvnsubsnext  [nars]        Test of ydb_subscript_next_s() function for local variables in the simpleAPI
# lvnsubsprev  [nars]        Test of ydb_subscript_previous_s() function for local variables in the simpleAPI
# lvnnodenext  [nars]        Test of ydb_node_next_s() function for local variables in the simpleAPI
# lvnnodeprev  [nars]        Test of ydb_node_previous_s() function for local variables in the simpleAPI
# lvndata      [nars]        Test of ydb_data_s() function for local variables in the simpleAPI
# lvnincr      [nars]        Test of ydb_incr_s() function for local variables in the simpleAPI
# isvsubsnext  [nars]        Test of ydb_subscript_next_s() function for intrinsic special variables in the simpleAPI
# isvsubsprev  [nars]        Test of ydb_subscript_previous_s() function for intrinsic special variables in the simpleAPI
# isvnodenext  [nars]        Test of ydb_node_next_s() function for intrinsic special variables in the simpleAPI
# isvnodeprev  [nars]        Test of ydb_node_previous_s() function for intrinsic special variables in the simpleAPI
# isvdata      [nars]        Test of ydb_data_s() function for intrinsic special variables in the simpleAPI
# isvincr      [nars]        Test of ydb_incr_s() function for intrinsic special variables in the simpleAPI
# str2zwr      [nars]        Test of ydb_str2zwr_s() function in the simpleAPI
# zwr2str      [nars]        Test of ydb_zwr2str_s() function in the simpleAPI
#-------------------------------------------------------------------------------------

echo "simpleapi test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic "lvnset lvnsetstress stresstest gvnset isvset tp transid lvnget gvnget isvget threen1g wordfreq"
#NARSTODO setenv subtest_list_non_replic "$subtest_list_non_replic gvnsubsnext gvnsubsprev gvnnodenext gvnnodeprev gvndata gvnincr"
#NARSTODO setenv subtest_list_non_replic "$subtest_list_non_replic lvnsubsnext lvnsubsprev lvnnodenext lvnnodeprev lvndata lvnincr"
#NARSTODO setenv subtest_list_non_replic "$subtest_list_non_replic isvsubsnext isvsubsprev isvnodenext isvnodeprev isvdata isvincr"
#NARSTODO setenv subtest_list_non_replic "$subtest_list_non_replic str2zwr zwr2str"
setenv subtest_list_replic     ""

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
setenv subtest_exclude_list	""

# Disable certain heavyweight tests on single-cpu systems
if ($gtm_test_singlecpu) then
	setenv subtest_exclude_list "$subtest_exclude_list lvnsetstress stresstest lvnget gvnget threen1g"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "simpleapi test DONE."
