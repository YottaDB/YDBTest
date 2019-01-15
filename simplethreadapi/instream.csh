#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2017-2019 YottaDB LLC. and/or its subsidiaries.	#
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
# lvnset          [nars]        Test of ydb_set_st() function for Local variables in the SimpleThreadAPI
# lvnsetstress    [nars]        Stress test of ydb_set_st() function for Local variables in the SimpleThreadAPI
# stresstest      [nars]        Stress test of all ydb_*() functions in the SimpleThreadAPI
# gvnset          [estess,nars] Test of ydb_set_st() function for Global variables in the SimpleThreadAPI
# isvset          [estess]      Test of ydb_set_st() function for Intrinsic Special Variables in the SimpleThreadAPI
# tp              [nars]        Test of ydb_tp_st() function in the SimpleThreadAPI
# transid         [nars]        Test that transid specified in ydb_tp_st() does go into journal file
# lvnget          [estess,nars] Test of ydb_get_st() function for local variables in the SimpleThreadAPI
# gvnget          [estess,nars] Test of ydb_get_st() function for global variables in the SimpleThreadAPI
# isvget          [estess]      Test of ydb_get_st() function for ISVs in the SimpleThreadAPI
# wordfreq        [nars]        Use SimpleThreadAPI to find the frequency of words in an input text file
# gvnsubsnext     [nars]        Test of ydb_subscript_next_st() function for global variables in the SimpleThreadAPI
# gvnsubsprev     [nars]        Test of ydb_subscript_previous_st() function for global variables in the SimpleThreadAPI
# lvnsubsnext     [nars]        Test of ydb_subscript_next_st() function for local variables in the SimpleThreadAPI
# lvnsubsprev     [nars]        Test of ydb_subscript_previous_st() function for local variables in the SimpleThreadAPI
# isvsubsnext     [nars]        Test of ydb_subscript_next_st() function for intrinsic special variables in the SimpleThreadAPI
# isvsubsprev     [nars]        Test of ydb_subscript_previous_st() function for intrinsic special variables in the SimpleThreadAPI
# isvnodenext     [quinn]       Test of ydb_node_next_st() function for intrinsic special variables in the SimpleThreadAPI
# isvnodeprev     [quinn]       Test of ydb_node_previous_st() function for intrinsic special variables in the SimpleThreadAPI
# isvdata         [nars]        Test of ydb_data_st() function for intrinsic special variables in the SimpleThreadAPI
# isvincr         [nars]        Test of ydb_incr_st() function for intrinsic special variables in the SimpleThreadAPI
# gvnlvnnodenext  [quinn]       Test of ydb_node_next_st() function for global and local variables in the SimpleThreadAPI
# gvnlvnnodeprev  [quinn]       Test of ydb_node_previous_st() function for global and local variables in the SimpleThreadAPI
# nodenext        [estess]      Test of ydb_node_next_st() function in the SimpleThreadAPI (both local and global vars)
# nodeprev        [estess]      Test of ydb_node_previous_st() function in the SimpleThreadAPI (both local and global vars)
# forkncore       [estess]      Test of ydb_fork_n_core() function in the SimpleThreadAPI
# locks           [estess]      Test of ydb_lock_st() function in the SimpleThreadAPI
# incrdecr        [estess]      Test of ydb_lock_incr_st() and ydb_lock_decr_st() functions in the SimpleThreadAPI
# simpleapinest   [nars]        Test of SIMPLEAPINEST error
# time2long       [nars]        Test of TIME2LONG error
# insuffsubs      [nars]        Test of INSUFFSUBS error
# invnamecount    [nars]        Test of INVNAMECOUNT error
# namecount2hi    [nars]        Test of NAMECOUNT2HI error
# delete_excl     [nars]        Test of ydb_delete_excl_st()
# callintcommit   [nars]        Test of CALLINTCOMMIT error
# callintrollback [nars]        Test of CALLINTROLLBACK error
# fatalerror1     [nars]        Test of FATALERROR1 error
# fatalerror2     [nars]        Test of FATALERROR2 error
# gvnlvndata      [quinn]       Test of ydb_data_st() function for global and local variables in the SimpleThreadAPI
# gvnlvnincr      [quinn]       Test of ydb_incr_st() function for global and local variables in the SimpleThreadAPI
# gvnlvndelete    [....]        Test of ydb_delete_st() function for global and local variables in the SimpleThreadAPI
# str2zwr         [....]        Test of ydb_str2zwr_st() function in the SimpleThreadAPI
# zwr2str         [....]        Test of ydb_zwr2str_st() function in the SimpleThreadAPI
#-------------------------------------------------------------------------------------

echo "simplethreadapi test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic "lvnset lvnsetstress stresstest gvnset isvset tp transid lvnget gvnget isvget wordfreq"
setenv subtest_list_non_replic "$subtest_list_non_replic gvnsubsnext gvnsubsprev"
setenv subtest_list_non_replic "$subtest_list_non_replic lvnsubsnext lvnsubsprev"
setenv subtest_list_non_replic "$subtest_list_non_replic isvsubsnext isvsubsprev isvnodenext isvnodeprev isvdata isvincr"
setenv subtest_list_non_replic "$subtest_list_non_replic gvnlvnnodenext gvnlvnnodeprev"
setenv subtest_list_non_replic "$subtest_list_non_replic nodenext nodeprev forkncore locks incrdecr simpleapinest"
setenv subtest_list_non_replic "$subtest_list_non_replic time2long insuffsubs invnamecount namecount2hi delete_excl"
setenv subtest_list_non_replic "$subtest_list_non_replic callintcommit callintrollback fatalerror1 fatalerror2"
setenv subtest_list_non_replic "$subtest_list_non_replic gvnlvndata gvnlvnincr"
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
	setenv subtest_exclude_list "$subtest_exclude_list lvnsetstress stresstest lvnget gvnget"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "simplethreadapi test DONE."
