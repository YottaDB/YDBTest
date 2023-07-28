#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
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
#---------------------------------------------------------------------------------------------------------------------------------------------------
# ydb996      [nars]    Test that LISTENING TCP sockets can be passed
# ydb998      [sam]     TSTART should not open the default global directory
# ydbpython32 [sam]	CTRL-C on Flask Application terminates properly
# ydb994      [nars]    Test various code issues identified by fuzz testing
#---------------------------------------------------------------------------------------------------------------------------------------------------

echo "r140 test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic "ydb996 ydb998 ydbpython32 ydb994"
setenv subtest_list_replic     ""

if ($?test_replic == 1) then
       setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
       setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

setenv subtest_exclude_list    ""

# Python/Flask does not work well with ASAN. Disable ydbpython32.
# (We get the correct error: __asan::ReportDeadlySignal, but we don't want to see that)
source $gtm_tst/com/is_libyottadb_asan_enabled.csh
if ($gtm_test_libyottadb_asan_enabled) then
	setenv subtest_exclude_list "$subtest_exclude_list ydbpython32"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "r140 test DONE."
