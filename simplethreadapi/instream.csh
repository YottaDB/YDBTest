#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	#
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
# lvnset          		[nars]        Test of ydb_set_st() function for Local variables in the SimpleThreadAPI
# lvnsetstress    		[nars]        Stress test of ydb_set_st() function for Local variables in the SimpleThreadAPI
# stresstest      		[nars]        Stress test of all ydb_*() functions in the SimpleThreadAPI
# gvnset          		[estess,nars] Test of ydb_set_st() function for Global variables in the SimpleThreadAPI
# isvset         		[estess]      Test of ydb_set_st() function for Intrinsic Special Variables in the SimpleThreadAPI
# tp              		[nars]        Test of ydb_tp_st() function in the SimpleThreadAPI
# transid         		[nars]        Test that transid specified in ydb_tp_st() does go into journal file
# lvnget          		[estess,nars] Test of ydb_get_st() function for local variables in the SimpleThreadAPI
# gvnget          		[estess,nars] Test of ydb_get_st() function for global variables in the SimpleThreadAPI
# isvget          		[estess]      Test of ydb_get_st() function for ISVs in the SimpleThreadAPI
# wordfreq        		[nars]        Use SimpleThreadAPI to find the frequency of words in an input text file
# gvnsubsnext     		[nars]        Test of ydb_subscript_next_st() function for global variables in the SimpleThreadAPI
# gvnsubsprev     		[nars]        Test of ydb_subscript_previous_st() function for global variables in the SimpleThreadAPI
# lvnsubsnext     		[nars]        Test of ydb_subscript_next_st() function for local variables in the SimpleThreadAPI
# lvnsubsprev     		[nars]        Test of ydb_subscript_previous_st() function for local variables in the SimpleThreadAPI
# isvsubsnext     		[nars]        Test of ydb_subscript_next_st() function for intrinsic special variables in the SimpleThreadAPI
# isvsubsprev     		[nars]        Test of ydb_subscript_previous_st() function for intrinsic special variables in the SimpleThreadAPI
# isvnodenext     		[quinn]       Test of ydb_node_next_st() function for intrinsic special variables in the SimpleThreadAPI
# isvnodeprev     		[quinn]       Test of ydb_node_previous_st() function for intrinsic special variables in the SimpleThreadAPI
# isvdata         		[nars]        Test of ydb_data_st() function for intrinsic special variables in the SimpleThreadAPI
# isvincr         		[nars]        Test of ydb_incr_st() function for intrinsic special variables in the SimpleThreadAPI
# gvnlvnnodenext  		[quinn]       Test of ydb_node_next_st() function for global and local variables in the SimpleThreadAPI
# gvnlvnnodeprev  		[quinn]       Test of ydb_node_previous_st() function for global and local variables in the SimpleThreadAPI
# nodenext        		[estess]      Test of ydb_node_next_st() function in the SimpleThreadAPI (both local and global vars)
# nodeprev        		[estess]      Test of ydb_node_previous_st() function in the SimpleThreadAPI (both local and global vars)
# forkncore       		[estess]      Test of ydb_fork_n_core() function in the SimpleThreadAPI
# locks           		[estess]      Test of ydb_lock_st() function in the SimpleThreadAPI
# incrdecr        		[estess]      Test of ydb_lock_incr_st() and ydb_lock_decr_st() functions in the SimpleThreadAPI
# simpleapinest   		[nars]        Test of SIMPLEAPINEST error
# time2long       		[nars]        Test of TIME2LONG error
# insuffsubs      		[nars]        Test of INSUFFSUBS error
# invnamecount    		[nars]        Test of INVNAMECOUNT error
# namecount2hi    		[nars]        Test of NAMECOUNT2HI error
# delete_excl     		[nars]        Test of ydb_delete_excl_st()
# callintcommit   		[nars]        Test of CALLINTCOMMIT error
# callintrollback 		[nars]        Test of CALLINTROLLBACK error
# fatalerror1     		[nars]        Test of FATALERROR1 error
# fatalerror2     		[nars]        Test of FATALERROR2 error
# key2big	  		[quinn]       Test of KEY2BIG error
# gvsuboflow	  		[quinn]	      Test of GVSUBOFLOW error
# gvnlvndata      		[quinn]       Test of ydb_data_st() function for global and local variables in the SimpleThreadAPI
# gvnlvnincr      		[quinn]       Test of ydb_incr_st() function for global and local variables in the SimpleThreadAPI
# gvnlvndelete    		[quinn]       Test of ydb_delete_st() function for global and local variables in the SimpleThreadAPI
# isvdelete       		[quinn]       Test of ydb_delete_st() function for intrinsic special variables in the simpleAPI
# str2zwr         		[quinn]       Test of ydb_str2zwr_st() and ydb_zwr2str_st() functions in the simpleAPI
# utils_file	  		[quinn]       Test of ydb_file_name_to_id_t(), ydb_file_is_identical_t(), and ydb_file_id_free_t() in the SimpleThreadAPI
# threadedapinotallowed		[quinn]	      Test of THREADEDAPINOTALLOWED error
# utilfuncs       		[quinn]       Test of Utility Functions in the SimpleThreadAPI
# invtptrans			[quinn]	      test of INVTPTRANS error
# externalcall			[mmr]	      Test of SimpleThreadAPI and Utility functions on external calls
# exitFromTp			[mmr]	      Test that ydb_exit() issues INVYDBEXIT error when called inside ydb_tp_st()
# initFromTp			[mmr]	      Test that ydb_init() issues YDB_OK when called inside ydb_tp_st()
# tpnestto127			[mmr]	      Test of ydb_tp_st() after TPTOODEEP error still finishes transactions
# isMainMT			[mmr]	      Test of ydb_thread_is_main() works when called from multiple threads
# initMT			[mmr]	      Test of ydb_init() works when called form multiple threads while the process is in SimpleThreadAPI mode
# exitMT			[mmr]	      Test of ydb_exit() works when called from multiple threads while the process is in SimpleThreadAPI mode
# pseudoBank			[mmr]	      Test of simulated banking transactions using SimpleThreadAPI with 10 threads in ONE process
# #-------------------------------------------------------------------------------------

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
setenv subtest_list_non_replic "$subtest_list_non_replic callintcommit callintrollback fatalerror1 fatalerror2 key2big"
setenv subtest_list_non_replic "$subtest_list_non_replic gvsuboflow"
setenv subtest_list_non_replic "$subtest_list_non_replic gvnlvndata gvnlvnincr gvnlvndelete isvdelete str2zwr utils_file"
setenv subtest_list_non_replic "$subtest_list_non_replic threadedapinotallowed utilfuncs invtptrans externalcall exitFromTp"
setenv subtest_list_non_replic "$subtest_list_non_replic initFromTp tpnestto127 isMainMT initMT exitMT pseudoBank"
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
