#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	#
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
# ydb757 [nars]        Test that SET x=$ZYHASH(x) does not issue LVUNDEF error
# ydb775 [nars]        Test that LOCKS obtained inside TSTART/TCOMMIT are correctly released on TRESTART
# ydb782 [nars]        Test ydb_lock_incr_s() call in child process while parent process holds the lock
# ydb772 [sam, ksbhaskar] Utility label $$SRCDIR^%RSEL returns space separated list of source code directories
# ydb785 [estess]      Test that ydb_ci_t() and ydb_cip_t() get text of error message if error occurs in M code
# ydb734 [nars]        Test use cases that came up while fixing code issues identified by enabling address sanitizer
# ydb828 [nars]        Test various code issues identified by fuzz testing
#----------------------------------------------------------------------------------------------------------------------------------------------------------

echo "r134 test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic "ydb757 ydb775 ydb782 ydb772 ydb785 ydb734 ydb828"
setenv subtest_list_replic     ""

if ($?test_replic == 1) then
       setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
       setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

setenv subtest_exclude_list    ""

source $gtm_tst/com/is_libyottadb_asan_enabled.csh
if ($gtm_test_libyottadb_asan_enabled && ("clang" == $gtm_test_asan_compiler)) then
	# Disable Go testing if ASAN and CLANG. See similar code in "com/gtmtest.csh" for details.
	setenv subtest_exclude_list "$subtest_exclude_list ydb785"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "r134 test DONE."
