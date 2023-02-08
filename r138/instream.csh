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
# ydb980      [sam]     Test %YDBJNLF with triggers, transaction records, and long records
# ydb979      [estess]  Test that MUPIP FTOK can FTOK() repl instance files with -jnlpool/-recvpool with 255 char filename
# ydb964      [nars]    Test various code issues identified by fuzz testing
# zwr1MibSubs [nars]    Test that ZWRITE of lvn with 1MiB subscript does not assert fail
#---------------------------------------------------------------------------------------------------------------------------------------------------

echo "r138 test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic "ydb980 ydb964 zwr1MibSubs"
setenv subtest_list_replic     "ydb979"

if ($?test_replic == 1) then
       setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
       setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

setenv subtest_exclude_list    ""

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "r138 test DONE."
