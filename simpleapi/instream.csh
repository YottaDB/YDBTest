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
# lvnset          [nars]        Test of ydb_set_s() function for Local variables in the simpleAPI
# lvnsetstress    [nars]        Stress test of ydb_set_s() function for Local variables in the simpleAPI
# stresstest      [nars]        Stress test of all ydb_*() functions in the simpleAPI
# gvnset          [estess,nars] Test of ydb_set_s() function for Global variables in the simpleAPI
# isvset          [estess]      Test of ydb_set_s() function for Intrinsic Special Variables in the simpleAPI
# tp              [nars]        Test of ydb_tp_s() function in the simpleAPI
# transid         [nars]        Test that transid specified in ydb_tp_s() does go into journal file
# lvnget          [estess,nars] Test of ydb_get_s() function for local variables in the simpleAPI
# gvnget          [estess,nars] Test of ydb_get_s() function for global variables in the simpleAPI
# isvget          [estess]      Test of ydb_get_s() function for ISVs in the simpleAPI
# wordfreq        [nars]        Use simpleAPI to find the frequency of words in an input text file
# gvnsubsnext     [nars]        Test of ydb_subscript_next_s() function for global variables in the simpleAPI
# gvnsubsprev     [nars]        Test of ydb_subscript_previous_s() function for global variables in the simpleAPI
# gvnnodenext     [nars]        Test of ydb_node_next_s() function for global variables in the simpleAPI
# gvnnodeprev     [nars]        Test of ydb_node_previous_s() function for global variables in the simpleAPI
# gvndata         [nars]        Test of ydb_data_s() function for global variables in the simpleAPI
# gvnincr         [nars]        Test of ydb_incr_s() function for global variables in the simpleAPI
# lvnsubsnext     [nars]        Test of ydb_subscript_next_s() function for local variables in the simpleAPI
# lvnsubsprev     [nars]        Test of ydb_subscript_previous_s() function for local variables in the simpleAPI
# lvnnodenext     [nars]        Test of ydb_node_next_s() function for local variables in the simpleAPI
# lvnnodeprev     [nars]        Test of ydb_node_previous_s() function for local variables in the simpleAPI
# lvndata         [nars]        Test of ydb_data_s() function for local variables in the simpleAPI
# lvnincr         [nars]        Test of ydb_incr_s() function for local variables in the simpleAPI
# isvsubsnext     [nars]        Test of ydb_subscript_next_s() function for intrinsic special variables in the simpleAPI
# isvsubsprev     [nars]        Test of ydb_subscript_previous_s() function for intrinsic special variables in the simpleAPI
# isvnodenext     [nars]        Test of ydb_node_next_s() function for intrinsic special variables in the simpleAPI
# isvnodeprev     [nars]        Test of ydb_node_previous_s() function for intrinsic special variables in the simpleAPI
# isvdata         [nars]        Test of ydb_data_s() function for intrinsic special variables in the simpleAPI
# isvincr         [nars]        Test of ydb_incr_s() function for intrinsic special variables in the simpleAPI
# str2zwr         [nars]        Test of ydb_str2zwr_s() function in the simpleAPI
# zwr2str         [nars]        Test of ydb_zwr2str_s() function in the simpleAPI
# nodenext        [estess]      Test of ydb_node_next_s() function in the simpleAPI (both local and global vars)
# forkncore       [estess]      Test of ydb_fork_n_core() function in the simpleAPI
# locks           [estess]      Test of ydb_lock_s() function in the simpleAPI
# incrdecr        [estess]      Test of ydb_lock_incr_s() and ydb_lock_decr_s() functions in the simpleAPI
# simpleapinest   [nars]        Test of SIMPLEAPINEST error
# time2long       [nars]        Test of TIME2LONG error
# insuffsubs      [nars]        Test of INSUFFSUBS error
# invnamecount    [nars]        Test of INVNAMECOUNT error
# namecount2hi    [nars]        Test of NAMECOUNT2HI error
# delete_excl     [nars]        Test of ydb_delete_excl_s()
# callintcommit   [nars]        Test of CALLINTCOMMIT error
# callintrollback [nars]        Test of CALLINTROLLBACK error
# fatalerror1     [nars]        Test of FATALERROR1 error
# fatalerror2     [nars]        Test of FATALERROR2 error
#-------------------------------------------------------------------------------------

echo "simpleapi test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic "lvnset lvnsetstress stresstest gvnset isvset tp transid lvnget gvnget isvget wordfreq"
setenv subtest_list_non_replic "$subtest_list_non_replic gvnsubsnext gvnsubsprev"
#NARSTODO setenv subtest_list_non_replic "$subtest_list_non_replic gvnsubsprev gvnnodenext gvndata gvnincr"
setenv subtest_list_non_replic "$subtest_list_non_replic lvnsubsnext lvnsubsprev"
#NARSTODO setenv subtest_list_non_replic "$subtest_list_non_replic lvnnodenext lvndata lvnincr"
#NARSTODO setenv subtest_list_non_replic "$subtest_list_non_replic isvsubsnext isvsubsprev isvnodenext isvdata isvincr"
#NARSTODO setenv subtest_list_non_replic "$subtest_list_non_replic str2zwr zwr2str"
#NARSTODO setenv subtest_list_non_replic "$subtest_list_non_replic gvnnodeprev"
#NARSTODO setenv subtest_list_non_replic "$subtest_list_non_replic lvnnodeprev"
##NARSTODO setenv subtest_list_non_replic "$subtest_list_non_replic isvnodeprev"
setenv subtest_list_non_replic "$subtest_list_non_replic nodenext nodeprev forkncore locks incrdecr simpleapinest"
setenv subtest_list_non_replic "$subtest_list_non_replic time2long insuffsubs invnamecount namecount2hi delete_excl"
setenv subtest_list_non_replic "$subtest_list_non_replic callintcommit callintrollback fatalerror1 fatalerror2"
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

echo "simpleapi test DONE."
