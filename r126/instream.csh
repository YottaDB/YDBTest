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
# ydb431	   [mmr]   Test of default value of ydb_routines if not set on yottadb/mumps process startup
# v63006	   [mmr]   Test that 'ZCompile "bar2.edit"' issues NOTMNAME error instead of compiling
# ydb432	   [mmr]   Test that mumps -object will strip from the tail of a file one .o and/or one .m in that order
# ydb431	   [mmr]   test of default value of ydb_routines if not set on yottadb/mumps process startup
# ydb449	   [mmr]   Test that reverse $order/$query functions work correctly when $increment is in use
# v63007	   [mmr]   Test that sr_port/code_gen.c does not check triple chain validity in case of compile error
# ydb431	   [mmr]   Test of default value of ydb_routines if not set on yottadb/mumps process startup
# ydb438	   [mmr]   Test that LOCK with timeout of 0 always returns a unowned lock
# ydb446	   [mmr]   Test that ydb_ci/p() and ydb_ci/p_t() do not sig11 if the M callin return length is greater than the allocated buffer
# ydb440	   [mmr]   Test that yottadb will not optimize xecute lines if more commands follow it
# ydb460 	   [mmr]   Test of maximum line length for M source files currently 32766 (32KiB-2) characters
# ydb429	   [mmr]   Test of all ydb_env_set/unset functions
#----------------------------------------------------------------------------------------------------------------------------------------------------------

echo "r126 test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     "ydb429"
setenv subtest_list_non_replic ""
setenv subtest_list_non_replic "$subtest_list_non_replic ydb430 pseudoBank randomWalk ydb431 ydb454 v63006 ydb432"
setenv subtest_list_non_replic "$subtest_list_non_replic ydb449 v63007 ydb438 ydb446 ydb440 ydb460"
setenv subtest_list_replic     ""

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

setenv subtest_exclude_list    ""

# on pro builds filter out ydb440 as mumps -machine -lis does not work there
if ("pro" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list ydb440"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "r126 test DONE."
