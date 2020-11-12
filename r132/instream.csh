#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	#
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
# ydb627 [nars]      Test that $FNUMBER(num,"",N)=num when N is non-zero returns 0
# ydb551 [sp]        Test to check $ZSYSLOG() doesn't break formatting when certain strings passed
# ydb632 [estess]    Test if resuming after a signal in a TP callback routine can cause a hang.
# ydb581 [sp]        Test to see $ZPARSE() fetches symbolically linked files
# ydb657 [nars]      Test that replication connection happens using TLS 1.3 if OpenSSL >= 1.1.1 and TLS 1.2 otherwise
# ydb630 [sp]        Test to see that $ZSYSLOG() uses consistent process names for ydb process
#----------------------------------------------------------------------------------------------------------------------------------------------------------

echo "r132 test starts..."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic "ydb627 ydb551 ydb632 ydb581 ydb630"
setenv subtest_list_replic     "ydb657"
setenv subtest_list_replic     ""

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

setenv subtest_exclude_list    ""
# filter out test that needs to run pro-only
if ("pro" != "$tst_image") then
       setenv subtest_exclude_list "$subtest_exclude_list ydb632" # ydb632 generates core and stop in dbg, continues in pro
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "r132 test DONE."
