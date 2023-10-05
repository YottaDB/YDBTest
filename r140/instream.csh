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
# ydbpython32 [sam]     CTRL-C on Flask Application terminates properly
# ydb994      [nars]    Test various code issues identified by fuzz testing
# ydb1024     [nars]    Fix OPEN of a socket type file name to not assert fail in io_open_try.c
# ydb1026     [nars]    Test that ZWRITE to file output device with STREAM + NOWRAP does not split/break lines
# ydb1021     [nars]    Test that MUPIP SET JOURNAL is able to switch older format journal files (without a FILEEXISTS error)
# ydb1029     [nars]    Test an incorrect assert that used to exist in mdb_condition_handler() related to jobinterrupt
# ydb1030     [nars]    Test SRCBACKLOGSTATUS message in case of a passive source server has no misleading WARNING
#---------------------------------------------------------------------------------------------------------------------------------------------------

echo "r140 test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic "ydb996 ydb998 ydbpython32 ydb994 ydb1024 ydb1026 ydb1021 ydb1029 ydb1030"
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
