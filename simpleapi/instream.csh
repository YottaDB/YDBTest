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
#-------------------------------------------------------------------------------------
# List of subtests of the form "subtestname [author] description"
#-------------------------------------------------------------------------------------
# lvnset          		[nars]        Test of ydb_set_s() function for Local variables in the simpleAPI
# lvnsetstress    		[nars]        Stress test of ydb_set_s() function for Local variables in the simpleAPI
# stresstest      		[nars]        Stress test of all ydb_*() functions in the simpleAPI
# gvnset          		[estess,nars] Test of ydb_set_s() function for Global variables in the simpleAPI
# isvset          		[estess]      Test of ydb_set_s() function for Intrinsic Special Variables in the simpleAPI
# tp              		[nars]        Test of ydb_tp_s() function in the simpleAPI
# transid         		[nars]        Test that transid specified in ydb_tp_s() does go into journal file
# lvnget          		[estess,nars] Test of ydb_get_s() function for local variables in the simpleAPI
# gvnget          		[estess,nars] Test of ydb_get_s() function for global variables in the simpleAPI
# isvget          		[estess]      Test of ydb_get_s() function for ISVs in the simpleAPI
# wordfreq        		[nars]        Use simpleAPI to find the frequency of words in an input text file
# gvnsubsnext     		[nars]        Test of ydb_subscript_next_s() function for global variables in the simpleAPI
# gvnsubsprev     		[nars]        Test of ydb_subscript_previous_s() function for global variables in the simpleAPI
# lvnsubsnext     		[nars]        Test of ydb_subscript_next_s() function for local variables in the simpleAPI
# lvnsubsprev     		[nars]        Test of ydb_subscript_previous_s() function for local variables in the simpleAPI
# isvsubsnext     		[nars]        Test of ydb_subscript_next_s() function for intrinsic special variables in the simpleAPI
# isvsubsprev     		[nars]        Test of ydb_subscript_previous_s() function for intrinsic special variables in the simpleAPI
# isvnodenext     		[quinn]       Test of ydb_node_next_s() function for intrinsic special variables in the simpleAPI
# isvnodeprev     		[quinn]       Test of ydb_node_previous_s() function for intrinsic special variables in the simpleAPI
# isvdata         		[nars]        Test of ydb_data_s() function for intrinsic special variables in the simpleAPI
# isvincr         		[nars]        Test of ydb_incr_s() function for intrinsic special variables in the simpleAPI
# gvnlvnnodenext  		[quinn]       Test of ydb_node_next_s() function for global and local variables in the simpleAPI
# gvnlvnnodeprev  		[quinn]       Test of ydb_node_previous_s() function for global and local variables in the simpleAPI
# nodenext        		[estess]      Test of ydb_node_next_s() function in the simpleAPI (both local and global vars)
# nodeprev        		[estess]      Test of ydb_node_previous_s() function in the simpleAPI (both local and global vars)
# forkncore       		[estess]      Test of ydb_fork_n_core() function in the simpleAPI
# locks           		[estess]      Test of ydb_lock_s() function in the simpleAPI
# incrdecr        		[estess]      Test of ydb_lock_incr_s() and ydb_lock_decr_s() functions in the simpleAPI
# simpleapinest   		[nars]        Test of SIMPLEAPINEST error
# time2long       		[nars]        Test of TIME2LONG error
# insuffsubs      		[nars]        Test of INSUFFSUBS error
# invnamecount    		[nars]        Test of INVNAMECOUNT error
# namecount2hi    		[nars]        Test of NAMECOUNT2HI error
# delete_excl     		[nars]        Test of ydb_delete_excl_s()
# callintcommit   		[nars]        Test of CALLINTCOMMIT error
# callintrollback 		[nars]        Test of CALLINTROLLBACK error
# fatalerror1     		[nars]        Test of FATALERROR1 error
# fatalerror2     		[nars]        Test of FATALERROR2 error
# key2big	  		[quinn]	      Test of KEY2BIG error
# gvsuboflow	  		[quinn]	      Test of GVSUBOFLOW error
# gvnlvndata      		[quinn]       Test of ydb_data_s() function for global and local variables in the simpleAPI
# gvnlvnincr      		[quinn]       Test of ydb_incr_s() function for global and local variables in the simpleAPI
# gvnlvndelete    		[quinn]       Test of ydb_delete_s() function for global and local variables in the simpleAPI
# isvdelete       		[quinn]       Test of ydb_delete_s() function for intrinsic special variables in the simpleAPI
# str2zwr         		[quinn]       Test of ydb_str2zwr_s() and ydb_zwr2str_s() functions in the simpleAPI
# utils_file	  		[quinn]	      Test of ydb_file_name_to_id(), ydb_file_is_identical(), and ydb_file_id_free() in the SimpleAPI
# simpleapinotallowed	 	[quinn]	      Test of errors in the SimpleAPI
# utilfuncs       		[quinn]       Test of Utility Functions in the SimpleAPI
#-------------------------------------------------------------------------------------

echo "simpleapi test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic "lvnset lvnsetstress stresstest gvnset isvset tp transid lvnget gvnget isvget wordfreq"
setenv subtest_list_non_replic "$subtest_list_non_replic gvnsubsnext gvnsubsprev"
setenv subtest_list_non_replic "$subtest_list_non_replic lvnsubsnext lvnsubsprev"
setenv subtest_list_non_replic "$subtest_list_non_replic isvsubsnext isvsubsprev isvnodenext isvnodeprev isvdata isvincr"
setenv subtest_list_non_replic "$subtest_list_non_replic gvnlvnnodenext gvnlvnnodeprev"
setenv subtest_list_non_replic "$subtest_list_non_replic nodenext nodeprev forkncore locks incrdecr simpleapinest"
setenv subtest_list_non_replic "$subtest_list_non_replic time2long insuffsubs invnamecount namecount2hi delete_excl"
setenv subtest_list_non_replic "$subtest_list_non_replic callintcommit callintrollback fatalerror1 fatalerror2 key2big"
setenv subtest_list_non_replic "$subtest_list_non_replic gvsuboflow"
setenv subtest_list_non_replic "$subtest_list_non_replic gvnlvndata gvnlvnincr gvnlvndelete isvdelete str2zwr utils_file"
setenv subtest_list_non_replic "$subtest_list_non_replic simpleapinotallowed utilfuncs"
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
