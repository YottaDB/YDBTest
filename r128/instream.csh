#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2019-2024 YottaDB LLC and/or its subsidiaries.	#
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
# v63006		[mmr]		Test that causing >32 lock collisions during a table resize does not fail the >32 collisions assert
# v63006B		[mmr]		New r128/V63006B subtest to test that mumps command will compile multiple M files interactively
# v63006C		[mmr]		New r128/V63006C subtest to test that mupip trigger -select prints a newline (just a newline) after being ran interactively
# ydb469		[see]		Test new $FNUMBER() formatting option
# ydb477		[see]		New test to verify that $TEST can be NEW'd
# ydb478		[see]		New test to verify after ydb_exit() a Go signal handler altstack is still in place
# ydb480		[see]		New test to verify $incr() of non-existant var or var set to 0 with floating pt value works
#----------------------------------------------------------------------------------------------------------------------------------------------------------

echo "r128 test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic "v63006 v63006B v63006C ydb469 ydb477 ydb480 ydb478"
setenv subtest_list_replic     ""

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

setenv subtest_exclude_list    ""
# filter out test that needs to run pro-only (dbg gets different results because of how gtm_fork_n_core() works)
if ("pro" != "$tst_image") then
       setenv subtest_exclude_list "$subtest_exclude_list ydb478"
endif

source $gtm_tst/com/is_libyottadb_asan_enabled.csh
if ($gtm_test_libyottadb_asan_enabled && ("clang" == $gtm_test_asan_compiler) && $ydb_test_gover_lt_118_or_rhel) then
	# Disable Go testing if ASAN and CLANG. See similar code in "com/gtmtest.csh" for details.
	setenv subtest_exclude_list "$subtest_exclude_list ydb478"
endif

if ("pro" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "r128 test DONE."
